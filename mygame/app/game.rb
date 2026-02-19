module App
  SPRITESHEET_PATH = "sprites/kenney_1-bit-pack/tilesheet/colored.png"
  SPRITESHEET_EXTENSIONS_PATH = "sprites/1bit-extensions.png"
  TILE_SIZE = 16

  require "app/entities/player"
  require "app/scenes/play_scene"
  require "app/scenes/spritesheet_scene"

  class Game
    attr_accessor :scene_manager

    def initialize
      @scene_manager = SpriteKit::SceneManager.new(
        current_scene: :play_scene,
        scenes: {
          play_scene: App::Scenes::PlayScene,
          spritesheet_scene: App::Scenes::SpritesheetScene
        }
      )
    end

    def current_scene
      @scene_manager.current_scene
    end

    def ticking_scene
      @scene_manager.ticking_scene
    end

    def tick(args)
      @scene_manager.tick(args)

      if args.inputs.keyboard.key_down.close_square_brace
        next_scene = @scene_manager.current_scene == :play_scene ? :spritesheet_scene : :play_scene
        @scene_manager.next_scene = next_scene
      end
    end
  end
end
