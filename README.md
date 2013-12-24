# AntColonyTsp

    Ant colony to solve travelling salesman

## Installation

Add this line to your application's Gemfile:

    gem 'ant_colony_tsp'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ant_colony_tsp

## Usage

    AntColonyTsp::AntColonyTsp.new.search([[565,575],[25,185]], 100, 10, 0.1, 2.5, 0.1, 0.9)
    100 - max iterations
    10 - number of ants
    0.1 - decay
    2.5 - heur
    0.1 - local pheromone
    0.9 - greedy

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
