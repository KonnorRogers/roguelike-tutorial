module App
  ITEMS = {
    health_potion:    lambda { |engine| App::Entities::Items::HealthPotion.new(engine: engine, amount: 4) },
    confusion_scroll: lambda { |engine| App::Entities::Items::ConfusionScroll.new(engine: engine, max_turns: 4) },
    lightning_potion: lambda { |engine| App::Entities::Items::LightningPotion.new(engine: engine, damage: 20, maximum_range: 5) }
  }
end
