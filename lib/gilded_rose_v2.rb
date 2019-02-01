require 'active_support/inflector'

# More readable version of Gilded Rose class
class GildedRoseV2
  attr_reader :name, :lookup, :days_remaining, :quality

  ITEM_HASH = {
    normal_item: :quality_decreases,
    aged_brie: :quality_increases,
    sulfuras_hand_of_ragnaros: :quality_stays_the_same,
    backstage_passes_to_a_tafkal80etc_concert: :quality_rapidly_increases,
    conjured_mana_cake: :quality_rapidly_decreases
  }.freeze

  TRAITS = {
    # logically the first should be a 2 but we use a map and increment each time
    quality_rapidly_increases: 1,
    quality_increases: 1,
    quality_stays_the_same: 0,
    quality_decreases: -1,
    quality_rapidly_decreases: -2
  }.freeze

  NO_QUALITY = 0
  MAX_QUALITY = 50
  NO_DAYS_REMAINING_ON_SELL_DATE = 0
  DAYS_WHERE_QUALITY_INCREASES = [11, 6].freeze
  DAYS_TO_DECREMENT = 1

  def initialize(name:, days_remaining:, quality:)
    @name = name
    # symbols are faster than strings
    @lookup = name.parameterize.underscore.to_sym
    @days_remaining = days_remaining
    @quality = quality
  end

  def tick
    change_quality
    rapidly_increase_quality

    decrement_days_remaining

    return unless no_days_remaining

    if ITEM_HASH[lookup].equal?(:quality_rapidly_increases)
      zero_out_quality
    else
      change_quality
    end
  end

  private

  def change_quality
    return unless (quality_step.positive? && quality < MAX_QUALITY) ||
                  (quality_step.negative? && quality > NO_QUALITY)

    @quality += quality_step
  end

  def rapidly_increase_quality
    return unless ITEM_HASH[lookup].equal? :quality_rapidly_increases

    DAYS_WHERE_QUALITY_INCREASES.map do |day_that_matters|
      change_quality if days_remaining < day_that_matters
    end
  end

  def zero_out_quality
    @quality = NO_QUALITY
  end

  def quality_step
    TRAITS[ITEM_HASH[lookup]]
  end

  def decrement_days_remaining
    return if ITEM_HASH[lookup].equal? :quality_stays_the_same

    @days_remaining -= DAYS_TO_DECREMENT
  end

  def no_days_remaining
    days_remaining < NO_DAYS_REMAINING_ON_SELL_DATE
  end
end
