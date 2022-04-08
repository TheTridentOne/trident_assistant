# TridentAssistant

A CLI tool to play with [Trident NFT Marketplace](https://thetrident.one)

## Installation

    $ gem install trident_assistant

## Usage

    $ ta

```
Commands:
  ta collectible     # commands for collectible
  ta collection      # commands for collection
  ta help [COMMAND]  # Describe available commands or one specific command
  ta metadata        # commands for metadata
  ta nfo             # commands for nfo
  ta order           # commands for order
  ta version         # Display TridentAssistant version

Options:
  -E, [--endpoint=ENDPOINT]      # Specify an endpoint
  -P, [--pretty], [--no-pretty]  # Print output in pretty
                                 # Default: true
```

### Collectible

    $ ta collectible

```
Commands:
  ta collectible airdrop COLLECTION, TOKEN k, --keystore=KEYSTORE  # airdrop NFT
  ta collectible bulkairdrop DIR k, --keystore=KEYSTORE            # Airdrop NFT in bulk
  ta collectible deposit COLLECTION TOKEN k, --keystore=KEYSTORE   # deposit NFT
  ta collectible help [COMMAND]                                    # Describe subcommands or one specific subcommand
  ta collectible index k, --keystore=KEYSTORE                      # query collectibles in wallet
  ta collectible show COLLECTION TOKEN k, --keystore=KEYSTORE      # query collectible
  ta collectible withdraw COLLECTION TOKEN k, --keystore=KEYSTORE  # withdraw NFT
```

### collection

    $ ta collection

```
Commands:
  ta collection create k, --keystore=KEYSTORE     # create a new collection
  ta collection help [COMMAND]                    # Describe subcommands or one specific subcommand
  ta collection index k, --keystore=KEYSTORE      # query all collections
  ta collection show ID k, --keystore=KEYSTORE    # query a collection
  ta collection update ID k, --keystore=KEYSTORE  # update collection
```

### metadata

    $ ta metadata

```
Commands:
  ta metadata help [COMMAND]                                        # Describe subcommands or one specific subcommand
  ta metadata new k, --keystore=KEYSTORE                            # generate a new metadata
  ta metadata show METAHASH k, --keystore=KEYSTORE                  # query metadata via metahash
  ta metadata upload k, --keystore=KEYSTORE m, --metadata=METADATA  # upload metadata to Trident
```

### nfo

    $ ta nfo

```
Commands:
  ta nfo bulkmint DIR k, --keystore=KEYSTORE                 # Mint NFT in bulk
  ta nfo help [COMMAND]                                      # Describe subcommands or one specific subcommand
  ta nfo mint k, --keystore=KEYSTORE m, --metadata=METADATA  # Mint NFT from NFO
```

### order

    $ ta order

```
Commands:
  ta order auction                           # auction NFT
  ta order bid                               # bid NFT
  ta order cancel ID k, --keystore=KEYSTORE  # cancel order
  ta order fill ID k, --keystore=KEYSTORE    # fill order
  ta order help [COMMAND]                    # Describe subcommands or one specific subcommand
  ta order index k, --keystore=KEYSTORE      # list orders
  ta order sell                              # sell NFT at fixed price
  ta order show ID k, --keystore=KEYSTORE    # query order
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TheTridentOne/trident_assistant. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/trident_assistant/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TridentAssistant project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/trident_assistant/blob/master/CODE_OF_CONDUCT.md).
