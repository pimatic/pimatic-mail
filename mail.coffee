# #Mail Plugin


module.exports = (env) ->

  # Require [convict](https://github.com/mozilla/node-convict) for config validation.
  convict = env.require "convict"

  # Require the [Q](https://github.com/kriskowal/q) promise library
  Q = env.require 'q'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  #Matcher to match the input predicate and supply autocomplete
  M = env.matcher

  nodemailer = require "nodemailer"

  mailTransport = null

  # ###Pushover class
  class Mail extends env.plugins.Plugin

    # ####init()
    init: (app, @framework, config) =>
      # Require your config shema
      @conf = convict require("./mail-config-schema")
      # and validate the given config.
      @conf.load config
      @conf.validate()
      # You can use `@confmyOption"` to get a config option.
      
      mailTransport = nodemailer.createTransport(
        @conf.get("transport"), 
        @conf.get("transportOptions")
      )
      
      @framework.ruleManager.addActionProvider(new MailActionProvider @framework, @conf)
  
  # Create a instance of my plugin
  plugin = new Mail 

  class MailActionProvider extends env.actions.ActionProvider
  
    constructor: (@framework, @conf) ->

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
          optionsTokens[opt] = strToTokens @conf.get(opt)
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
