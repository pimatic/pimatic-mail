# #Mail Plugin


module.exports = (env) ->

  Q = env.require 'q'
  assert = env.require 'cassert'
  M = env.matcher

  nodemailer = require "nodemailer"

  mailTransport = null

  # ###Pushover class
  class Mail extends env.plugins.Plugin

    # ####init()
    init: (app, @framework, @config) =>
      
      mailTransport = nodemailer.createTransport(
        config.transport 
        config.transportOptions
      )
      
      @framework.ruleManager.addActionProvider(new MailActionProvider @framework, config)
  
  # Create a instance of my plugin
  plugin = new Mail 

  class MailActionProvider extends env.actions.ActionProvider
  
    constructor: (@framework, @config) ->

    parseAction: (input, context) =>

      # Helper to convert 'some text' to [ '"some teyt"' ]
      strToTokens = (str) => ["\"#{str}\""]

      m = M(input, context)
        .match('send ', optional: yes)
        .match(['mail'])

      options = ["from", "to", "subject", "text"]
      optionsTokens = {}

      for opt in options
        do (opt) =>
          optionsTokens[opt] = strToTokens @config[opt]
          next = m.match(" #{opt}:").matchStringWithVars( (m, tokens) =>
            optionsTokens[opt] = tokens
          )
          if next.hadMatch() then m = next

      if m.hadMatch()
        match = m.getFullMatch()
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
      mailOptions = {}
      awaiting = []
      for name, tokens of @optionsTokens
        do (name, tokens) => 
          p = @framework.variableManager.evaluateStringExpression(tokens).then( (value) =>
            mailOptions[name] = value
          )
          awaiting.push p
      Q.all(awaiting).then( =>
        if simulate
          # just return a promise fulfilled with a description about what we would do.
          return __(
            "would send mail to \"%s\" with message \"%s\"", 
            mailOptions.to, mailOptions.message)
        else
          return Q.ninvoke(mailTransport, "sendMail", mailOptions).then( (statusCode) => 
            __("mail sent with status: %s", statusCode.message) 
          )
      )

  module.exports.MailActionProvider = MailActionProvider

  # and return it to the framework.
  return plugin   
