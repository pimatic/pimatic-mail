# #mail plugin configuration options
module.exports = {
  title: "mail config"
  type: "object"
  properties:
    # https://www.npmjs.org/package/nodemailer
    transport:
      description: "The transport to use for nodemailer"
      type: "string"
      enum: ["SMTP", "SES", "sendmail", "PICKUP", "direct", "stub"]
      default: "sendmail"
    transportOptions:
      description: "The Transport options"
      type: "object"
      default: {}
    from: 
      description: "default from e-mail address"
      type: "string"
      default: "pimatic <no-reply@pimatic.org>"
    to:
      description: "default to e-mail address"
      type: "string"
      default: "nobody <nobody@example.com>"
    subject: 
      description: "default e-mail subject"
      type: "string"
      default: "pimatic message"
    text: 
      description: "default e-mail text"
      type: "string"
      default: "42"
}