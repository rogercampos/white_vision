# WhiteVision

White Vision is a simple email platform to provide your application with basic emailing capabilities. It works as a mountable Engine on your ruby on rails application and provides a UI as well as a programmable API to perform operations.

The goal of this tool is to provide you with a way to create and send emails, as well as a way to keep track of emailing activity. You can define a *success rule* for any email sent (like opening, or clicking some specific link) and then know which ones of the sent emails are now a success. All other related events are also recorded (email received, opened, clicked, etc.). But nothing more, for example, you won't be able to define "entire emailing flows". Instead you can do that on your own and use this tool just to send the emails at the correct time, calculated by you.

This tool uses Sendgrid as the underlaying email provider, using its [events webhook]() to know about activity.


## Sendgrid Integration

As mentioned, you'll need a Sendgrid account to work with WhiteVision. At the time of writing, you can get a free account and send up to 100 emails per day. 

The configuration needed will be the **sendgrid_api_key**, and you'll have to configure a webhook in sendgrid pointing to `/white_vision/sendgrid_event_callback` in order to capture events.
 


## Using the programmable API

Email body must be provided as-is, in HTML form. In can include substitutions in the form of "=name=", for example. You can use anything, you'll have to provide real values later on when sending the email (if not all substitutions are provided an error will be raised).

Define emails as ruby classes, and then send them out to recipients from your app. Interpolations can be given at runtime. It's recommended that you create some base classes or mixins to define common behaviour, for example to separate "transactional" emails from "marketing" ones.



## Using the UI

Using the UI you can create email templates to later on send emails to recipients. Creating an email template is a 2-step process. 

First you create it as a draft, where data can be imcomplete. In this state you can provide test values for substitutions, check the resulting email in the browser and perform a test send (but for real) to a test recipient as configured from the code.

Contrary to the programmable usage, options are more limited here, as can be expected. It works by providing the following config from the app:


```ruby
# config/initializers/white_vision.rb
  
Config.recipient_klass = Subscriber
Config.recipient_klass_attribute = :email
Config.testing_only_recipients = ["roger@rogercampos.com"]
Config.send_scopes = {
  active_list: -> (rel) { rel.active.not_bounced },
  premium_list: -> (rel) { rel.premium }
}
Config.substitutions = {
  '=name=' => proc { |subscriber| subscriber.name },
  '=cancelation_url=' => proc { |subscriber| Rails.routes.cancel_url(tk: subsciber.cancel_token) }
}  
```

- `recipient_klass` will be an AR class that holds your representation of a possible "recipient". Maybe a dedicated class like `Subscriber` or a more general thing like `User`. 
- The `recipient_klass_attribute` is the attribute from that class that's expected to hold the real recipient to deliver to (note this can be a ruby method, not a db column). 
- The `testing_only_recipients` will be the allowed recipients to send test emails during testing phase. 
- The `send_scopes` will be the possible "collections" to send the real email later on. 
- And finally the `substitutions` will be the set of optional substitutions your emails can contain, passing a lambda to each one to calculate the final value from an instance of the given `recipient_klass`.


When you're confident about the draft, you can promote it to "finished". Now the template cannot be further edited (nor deleted), and you can now deliver it to any of the "sending scopes" defined in the config. When you no longer need an email template, you can "archive" it, it won't bother you anymore.

Using the UI you can only sent "context-less" emails to recipients, so it must be a pretty simple thing. Things like generic campaigns or offers, or adhoc messages. For doing more complex things like "I noticed you have this product in the cart and I want you to finish your order, showing you the exact product" or more context-aware things like that, you must use the programmable API. 
 
In the UI you can also previsualize the emails created in the app, but with no substitutions.

"template_id"'s cannot be repeated, so we will validate them at creation time and also at the time an email is sent (it may be possible that you use a given template_id in an email created from the UI and later on you reuse the same one from an email hardcoded in the app. In this case, an error will be raised when you'll try to send an email with that template.) 



## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'white_vision'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install white_vision
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
