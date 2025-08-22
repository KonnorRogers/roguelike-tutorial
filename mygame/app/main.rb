# Always first.
require "vendor/sprite_kit/sprite_kit.rb"
require "app/game.rb"

def tick(args)
  $game ||= App::Game.new
  $game.tick(args)
end

def reset
  $game = nil
end

$gtk.reset
