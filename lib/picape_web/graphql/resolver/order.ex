defmodule PicapeWeb.Graphql.Resolver.Order do

  alias Picape.Order

# Queries

  def current(_parent, _args, _info) do
    Order.current()
  end

  def recipies_planned?(_, recipe_ids) do
    {:ok, planned_ids} = Order.planned_recipes(1)

    Map.new(recipe_ids, fn id -> {id, Enum.member?(planned_ids, id)} end)
  end

  def ingredients_planned?(_, ingredient_ids) do
    {:ok, ingredients} = Order.ingredients_planned?(1, ingredient_ids)

    ingredients
  end

  def ingredients_ordered_quantity(_, ingredient_ids) do
    {:ok, ingredients} = Order.ingredients_ordered_quantity(1, ingredient_ids)

    ingredients
  end

# Mutations

  def plan_recipe(attributes, _info) do
    Order.plan_recipe(1, attributes[:recipe_id], false)
  end

  def unplan_recipe(attributes, _info) do
    Order.plan_recipe(1, attributes[:recipe_id], true)
  end

  def sync_supermarket(attributes, _info) do
    Order.sync_supermarket(1)
  end

  def order_ingredient(attributes, _info) do
    Order.order_ingredient(1, attributes[:ingredient_id], attributes[:quantity])
  end
end
