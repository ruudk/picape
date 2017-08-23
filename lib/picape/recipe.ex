defmodule Picape.Recipe do
  import Ecto.Query

  alias Picape.Repo
  alias Picape.Supermarket
  alias Picape.Recipe.{Ingredient, IngredientRef, Recipe}

  def list_recipes() do
    Repo.all(
      from recipe in Recipe
      # preload: [ingredients: :ingredient]
    )
  end

  def recipes_by_ids(ids) do
    result = from(r in Recipe, where: r.id in ^ids)
    |> Repo.all
    |> Map.new(fn recipe -> {recipe.id, recipe} end)

    {:ok, result}
  end

  def ingredients_by_ids(ids) do
    result = from(i in Ingredient, where: i.id in ^ids)
    |> Repo.all
    |> Map.new(fn ingredient -> {ingredient.id, ingredient} end)

    {:ok, result}
  end

  @doc """
  Returns a map of items and their quantities needed
  for the specified map of recipes and their quantities.

  This excludes essentials.
  """
  def item_quantities(recipes_quantities) do
    query = from r in IngredientRef,
      join: i in assoc(r, :ingredient),
      where: r.recipe_id in ^Map.keys(recipes_quantities) and
             i.is_essential == false,
      select: {i.supermarket_product_id, {r.recipe_id, r.quantity}}

    result = Repo.all(query)
    |> Enum.map(fn ({id, {recipe_id, quantity}}) ->
       {id, recipes_quantities[recipe_id] * quantity}
    end)
    |> Enum.into(%{})

    {:ok, result}
  end

  def ingredients_by_item_ids(item_ids) do
    result = (from i in Ingredient,
      where: i.supermarket_product_id in ^item_ids,
      select: {i.supermarket_product_id, i})
      |> Repo.all
      |> Enum.into(%{})

    {:ok, result}
  end

  def ingredients_by_item_ids_reverse(item_ids) do
    {:ok, ingredients} = ingredients_by_item_ids(item_ids)
    ids = Map.new(ingredients, fn {k, ingredient} -> {k, ingredient.id} end)

    {:ok, Map.new(item_ids, fn item_id -> {ids[item_id], item_id} end)}
  end

  def ingredients_by_recipe_ids(recipe_ids) do
    result = Repo.all(from r in IngredientRef,
      where: r.recipe_id in ^recipe_ids,
      join: i in assoc(r, :ingredient),
      select: {r.recipe_id, i})
      |> Enum.group_by(fn {k, _} -> k end, fn {_, v} -> v end)

    {:ok, result}
  end

  def recipes_by_ingredient_ids(ingredient_ids, recipe_ids) do
    result = Repo.all(from ref in IngredientRef,
      where: ref.recipe_id in ^recipe_ids and ref.ingredient_id in ^ingredient_ids,
      join: r in assoc(ref, :recipe),
      select: {ref.ingredient_id, ref},
      preload: [:recipe])
      |> Enum.group_by(fn {k, _} -> k end, fn {_, v} -> v end)

    {:ok, result}
  end

  @doc """
  Returns if each ingredient that is in one of the specified recipes.
  """
  def ingredients_in_recipes?(recipe_ids, ingredient_ids) do
    ids = Repo.all from r in IngredientRef,
       where: r.recipe_id in ^recipe_ids and
              r.ingredient_id in ^ingredient_ids,
       select: r.ingredient_id

    {:ok, Map.new(ingredient_ids, fn id -> {id, Enum.member?(ids, id)} end)}
  end

  def list_essentials() do
    Ingredient
    |> where(is_essential: true)
    |> Repo.all
  end

  def search_ingredient(query, excluded) do
    Repo.all(from i in Ingredient,
      where: not i.id in ^excluded and
      ilike(i.name, ^("%#{query}%")) )
  end

  def add_ingredient(params) do
    %Ingredient{}
    |> Ingredient.add_changeset(Map.put(params, :supermarket_product_raw, Supermarket.products_by_id(params[:supermarket_product_id])))
    |> Repo.insert
  end

  def edit_ingredient(params) do
    Repo.get(Ingredient, params[:ingredient_id])
    |> Ingredient.edit_changeset(params)
    |> Repo.update
  end

  def delete_ingredient(params) do
    Repo.get(Ingredient, params[:ingredient_id])
    |> Repo.delete
  end

  def add_recipe(params) do
    %Recipe{}
    |> Recipe.add_changeset(params)
    |> Repo.insert
  end

  def edit_recipe(params) do
    Repo.get(Recipe, params[:id])
    |> Repo.preload(:ingredients)
    |> Recipe.edit_changeset(params)
    |> Repo.update
  end

  def match_supermarket_products() do
    Ingredient
    |> Repo.all
    |> Enum.map(fn ingredient ->
      ingredient
      |> Ingredient.raw_changeset(%{supermarket_product_raw: Supermarket.products_by_id(ingredient.supermarket_product_id)})
    end)
    |> Enum.map(&Repo.update!/1)
  end
end
