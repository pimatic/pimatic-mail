# #Mail Plugin


module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  M = env.matcher
  _ = env.require 'lodash'

  nodemailer = require "nodemailer"

  mailTransport = null

  # ###Pushover class
  class Mail extends env.plugins.Plugin

    # ####init()
    init: (app, @framework, @config) =>

      mailTransport = nodemailer.createTransport(
        @config.transport
        _.clone(@config.transportOptions, true)
      )
      Promise.promisifyAll(mailTransport)

      @framework.ruleManager.addActionProvider(new MailActionProvider @framework, @config)

  # Create a instance of my plugin
  plugin = new Mail

  class MailActionProvider extends env.actions.ActionProvider

    constructor: (@framework, @config) ->
      @mailOptionKeys = ["from", "to", "subject", "html", "text", "file"]
      @configWithDefaults = _.assign @config.__proto__, @config

    parseAction: (input, context) =>

      # Helper to convert 'some text' to [ '"some text"' ]
      strToTokens = (str) => ["\"#{str}\""]

      m = M(input, context)
        .match('send ', optional: yes)
        .match(['mail'])

      # matched tokens
      optionsTokens = {}
      # set of option keys matched
      optionsSet = []
      # list of action option patterns derived for @mailOptionKeys
      # if a pattern has been matched it will be removed unless the option
      # may occur multiple times as it is the case for "to" and "file"
      mailOptionsPatterns = []
      for key in @mailOptionKeys
        mailOptionsPatterns.push [key, " #{key}:"]
        
      condition = true
      index = 0
      while condition
        next = null
        m.match(mailOptionsPatterns, (m, opt) =>
          m.matchStringWithVars( (m, tokens) =>
            optionsSet.push opt
            unless opt is "file" or opt is "to"
              optionsTokens[opt] = tokens
              # remove matched pattern from mailOptionsPatterns as all options except file 
              # may only occur once
              mailOptionsPatterns = mailOptionsPatterns.filter (item) -> item[0] isnt opt
            else
              # we could make this an array...
              optionsTokens[opt + index++] = tokens
            next = m
          )
        )
        condition = next?
        m = next if condition

      if m.hadMatch()
        match = m.getFullMatch()

        # Set default values for unset options
        for opt in @mailOptionKeys
          if opt not in optionsSet and @configWithDefaults.hasOwnProperty(opt)
            if opt isnt "text" or opt is "text" and not optionsTokens.hasOwnProperty "html"
              optionsTokens[opt] = strToTokens @configWithDefaults[opt]

        env.logger.debug "Matched tokens with defaults:", optionsTokens
        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new MailActionHandler(
            @framework, optionsTokens
          )
        }
      else
        return null


  class MailActionHandler extends env.actions.ActionHandler

    constructor: (@framework, @optionsTokens) ->

    executeAction: (simulate, context) ->
      mailOptions = {
        attachments: []
      }
      awaiting = []

      for name, tokens of @optionsTokens
        do (name, tokens) =>
          p = @framework.variableManager.evaluateStringExpression(tokens).then( (value) =>
            if /^file[0-9]{0,}$/.test(name)
              mailOptions.attachments.push {filePath: value}
            else if /^to[0-9]{0,}$/.test(name)
              key = name.replace(/[0-9]{0,}$/g, '')
              if mailOptions[key]
                mailOptions[key] = mailOptions[key] + "," + value
              else
                mailOptions[key] = value
            else
              mailOptions[name] = value
          )
          awaiting.push p

      Promise.all(awaiting).then( =>
        if simulate
          # just return a promise fulfilled with a description about what we would do.
          env.logger.debug "Options passed to nodemailer:", mailOptions
          return __(
            "would send mail to \"%s\" with message \"%s\"",
            mailOptions.to, mailOptions.text || mailOptions.html)
        else
          return mailTransport.sendMailAsync(mailOptions).then( (statusCode) =>
            __("mail sent with status: %s", statusCode.message)
          )
      )

  module.exports.MailActionProvider = MailActionProvider

  # and return it to the framework.
  return plugin   
