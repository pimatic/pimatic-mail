pimatic mail plugin
=======================


Provides an action handler to send mails from pimatic rules. It uses 
 [nodemailer v0.7](https://github.com/andris9/Nodemailer/blob/0.7/README.md) which supports all common mail transports.

Configuration
-------------
You can load the backend by editing your `config.json` to include:

    {
      "plugin": "mail",
      "transport": "SMTP",
      "transportOptions": {
        "service": "Gmail", // sets automatically host, port and connection security settings
        "auth": {
            "user": "gmail.user@gmail.com",
            "pass": "userpass"
        }
      },
      "to": "gmail.user@gmail.com"
    }

in the `plugins` section. For all configuration options see [mail-config-schema](mail-config-schema.html). The 
 transport options are transport dependent and listed at 
 [nodemailer v0.7](https://github.com/andris9/Nodemailer/blob/0.7/README.md).
 
Advanced Configuration Example for GMX
--------------------------------------

If your mail service provider is not on nodemailer's list of [well known services]
 (https://github.com/andris9/Nodemailer/blob/0.7/README.md#well-known-services-for-smtp) an advanced transport 
 configuration is required. Below, an example configuration for GMX is provided. This configuration deals 
 with some issues which may also apply to other mail service providers:
 
* Host and Port of the mail service. You can obtain this information from your mail service provider.
* The GMX SMTP mailer is picky about encryption ciphers used and, thus, the cipher suite used for pimatic
  must be set to 'SSLv3'
* The "from" address must be set explicitly to your mailbox address. Otherwise, the mail will be rejected 
  with error 550 which is provides a measure against misuse of mail addresses. You should set 
  the 'from' address as part of the plugin configuration.

Example:

    {
      "plugin": "mail",
      "transport": "SMTP",
      "transportOptions": {
        "host": "mail.gmx.com",
        "port": 587,
        "tls": {
          "ciphers": "SSLv3"
        },
        "auth": {
          "user": "Zaphod.Beeblebrox@gmx.de",
          "pass": "TopSecret"
        },
        "maxConnections": 5
      },
      "from": "Zaphod.Beeblebrox@gmx.de"
    }	


Usage
-----

You can send mail messages as part of rule actions. The "send mail" action supports the following 
modifiers:

* **to:** The mail recipient's address
* **from:** The mail sender's address
* **text:** An Unicode string containing the plaintext version of the message body. If, both, **text** 
 and **html** modifiers are absent, the default text will be used as defined by the plugin configuration
* **html:** An Unicode string containing the HTML version of the message body. If, both, **text** 
 and **html** modifiers are present, an e-mail with a multi-part body will be generated containing the 
 plain text and the HTML text
* **file:** A path to a file which will be attached to the mail

Generally, each modifier can only by applied once per mail action. For **to:** and **file:** modifiers, multiple 
 occurrences are supported.

Example Rule
------------

    IF it is 08:00 THEN send mail to:"gmail.user@gmail.com" subject:"Good morning!" text:"Good morning Dave!"
    

Credits
-------

<div>Icon made by <a href="http://www.unocha.org" title="OCHA">OCHA</a> is licensed under 
 <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>

