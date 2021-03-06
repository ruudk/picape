import React from "react";
import { Platform } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { TabNavigator, TabBarBottom } from "react-navigation";

import Colors from "../constants/Colors";

import HomeScreen from "../screens/HomeScreen";
import { IngredientsScreenWithData } from "../screens/IngredientsScreen";
import { RecipesScreenWithData } from "../screens/RecipesScreen";

export default TabNavigator(
  {
    Recipes: {
      screen: RecipesScreenWithData,
    },
    Ingredients: {
      screen: IngredientsScreenWithData,
    },
    Home: {
      screen: HomeScreen,
    },
  },
  {
    navigationOptions: ({ navigation }) => ({
      tabBarIcon: ({ focused }) => {
        const { routeName } = navigation.state;
        let iconName;
        switch (routeName) {
          case "Home":
            iconName =
              Platform.OS === "ios" ? `ios-information-circle${focused ? "" : "-outline"}` : "md-information-circle";
            break;
          case "Ingredients":
            iconName = Platform.OS === "ios" ? `ios-link${focused ? "" : "-outline"}` : "md-link";
            break;
          case "Recipes":
            iconName = Platform.OS === "ios" ? `ios-options${focused ? "" : "-outline"}` : "md-options";
        }
        return (
          <Ionicons
            name={iconName}
            size={28}
            style={{ marginBottom: -3 }}
            color={focused ? Colors.tabIconSelected : Colors.tabIconDefault}
          />
        );
      },
    }),
    tabBarComponent: TabBarBottom,
    tabBarPosition: "bottom",
    animationEnabled: false,
    swipeEnabled: false,
  },
);
