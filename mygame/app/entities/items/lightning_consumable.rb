require "app/entities/items/item"

module App
  module Entities
    module Items
      class LightningConsumable < Item
        # def __init__(self, damage: int, maximum_range: int):
        #     self.damage = damage
        #     self.maximum_range = maximum_range

        # def activate(self, action: actions.ItemAction) -> None:
        #     consumer = action.entity
        #     target = None
        #     closest_distance = self.maximum_range + 1.0

        #     for actor in self.engine.game_map.actors:
        #         if actor is not consumer and self.parent.gamemap.visible[actor.x, actor.y]:
        #             distance = consumer.distance(actor.x, actor.y)

        #             if distance < closest_distance:
        #                 target = actor
        #                 closest_distance = distance

        #     if target:
        #         self.engine.message_log.add_message(
        #             f"A lighting bolt strikes the {target.name} with a loud thunder, for {self.damage} damage!"
        #         )
        #         target.fighter.take_damage(self.damage)
        #         self.consume()
        #     else:
        #         raise Impossible("No enemy is close enough to strike.")
        #     end
        # end
      end
    end
  end
end
