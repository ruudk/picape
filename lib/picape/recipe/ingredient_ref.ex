defmodule Picape.Recipe.IngredientRef do
  use Ecto.Schema
  import Ecto.Changeset
  alias Picape.Recipe.IngredientRef

  schema "recipe_ingredient_ref" do
    field(:quantity, :integer)
    belongs_to(:ingredient, Picape.Recipe.Ingredient)
    belongs_to(:recipe, Picape.Recipe.Recipe)

    timestamps()
  end

  @doc false
  def changeset(%IngredientRef{} = ingredient_ref, attrs) do
    ingredient_ref
    |> cast(attrs, [:ingredient_id, :quantity])
    |> validate_required([:quantity])
  end
end
