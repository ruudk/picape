defmodule PicapeWeb.Graphql.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema

  alias PicapeWeb.Graphql.Resolver
  import_types PicapeWeb.Graphql.Types

  @node_id_rules %{
      recipe_id: :recipe,
  }

  node interface do
    resolve_type fn
      %Picape.Recipe.Recipe{}, _ ->
        :recipe
      %Picape.Recipe.Ingredient{}, _ ->
        :ingredient
      _, _ ->
        nil
    end
  end

  query do
    field :recipes, list_of(:recipe) do
      resolve &Resolver.Recipe.all/3
    end

    field :essentials, list_of(:ingredient) do
      resolve &Resolver.Recipe.essentials/3
    end

    field :current_order, :order do
      resolve &Resolver.Order.current/3
    end
  end

  mutation do
    @desc "Plan a recipe and order ingredients"
    field :plan_recipe, :order do
      arg :recipe_id, non_null(:id)
      resolve parsing_node_ids(&Resolver.Order.plan_recipe/2, @node_id_rules)
    end
  end

# Subscription example: https://github.com/absinthe-graphql/absinthe_phoenix
end
