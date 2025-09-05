# frozen_string_literal: true

# Always first.
require "vendor/sprite_kit/sprite_kit.rb"
require "app/game.rb"

def boot(args)
  args.state = {}
end


def tick(args)
  $game ||= App::Game.new
  $game.tick(args)
end

def reset
  $game = nil
end

$gtk.reset
