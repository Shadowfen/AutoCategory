## Creating or Modifying a Category
In order to create a custom category (rule), you will use some of the Rule Functions that AutoCategory understands in order to specify which items you want to include or exclude from the category.

When you create a new Category, the Category name that you give it will be the name that is used as a heading in your inventory above the items that belong to that category. You cannot have two categories with the same name.

The Tag for a new Category is a convenience for grouping Categories together for display in the AutoCategory Settings only. It is not used anywhere else.

The Description of a Category allows you to specify descriptive text which will be used as a tooltip for when you hover over a Category name in one of the dropdown menus of Categories in the AutoCategory Settings.

The Rule for a category is described below.

## Rule Expression Creation
The Rule section is where the actual decision making takes place. You are basically creating an expression which will evaluate to either true or false to say if the item is to be included (true) or excluded (false). (By the way, in Lua, anything that is not `true` is `false`.) Each item in the bag is evaluated against the rule, one after another and AutoCategory has a number of rule functions to be able to get information about or reason about the particular item being evaluated. These rule functions are used along with `and`s, `or`s, `not`s, and arithmetic comparisons in order to include/exclude items.

For instance you might use the simple rule `ismonsterset()` to create a category that will have all of your monster helms and shoulders in it. 

A slightly more complex rule might be to group all of the armor and weapons that you have whose level is lower than yours: `type("armor","weapons") and (itemlevel() < charlevel() or cp() < charcp())`. Notice in this rule, we have parentheses around the comparison of levels and champion points. This is to specify that these two expressions (level and champion points) are to be evaluated and then `or`ed with each other before that they are `and`ed with the `type()` expression. If the parentheses were left out you would not get the desired result, because `type("armor","weapons") and itemlevel() < charlevel() or cp() < charcp()` is actually the equivalent of `(type("armor","weapons") and itemlevel() < charlevel()) or cp() < charcp()` that would allow necklaces with champion points less than the character's to be listed as well - since the armor or weapons requirement would only be enforced against the itemlevel requirement. 

### Refresher on boolean operations
#### And
| expression | equals |
|------------|:------:|
|true and true| true |
|true and false| false|
|false and true | false |
|false and false | false |

#### Or
|expression|equals|
|----------|:----:|
|true or true|true|
|true or false|true|
|false or true|true|
|false or false|false|

#### Not
|expression| equals |
|----------|:------:|
|not true|false|
|not false|true|

## Rule Validation
In order to assist you in creating rules that can work, AutoCategory now does some basic checking on the rule you enter or modify and will display a "Good", "Warning", or "Error" tag and some more information regarding what the warning or error is about. 

* Error - Getting an Error means that the rule has no chance of even attempting to run. The explanatory text that goes with the error is the lua compiler trying to tell you what is wrong with the rule, because it cannot compile successfully as is.

* Warning - Getting a Warning means that the checker found some terms in the rule that it could not recognize. This does NOT mean that the rule is bad - only that you need to make sure that you did not have any typos where rule function names or particular arguments are concerned. The reason why your rule might be perfectly fine even with a warning is because certain of the rule functions take as arguments things like set names or other strings that the rule checker is not smart enough to recognize. For instance, the rule `itemname("Ring of Mara")` will report two strings that it does not recognize: "of", "Mara". The rule will still work just fine (although it would be a boring category with only a single item in it ever). On the other hand it can alert you when you accidentally type pstype() instead of sptype().

* Good - Getting a Good means that the rule compiles fine, and all of the strings are recognized by AutoCategory. The rule still might not do what you want, but you have a much better chance at getting something to work.

## Examples
### Example 1 - **Match multiple conditions**

Items matched by:

* Set is Necropotency
* Item level is cp 160
* Item trait is Divines or Infused
Rule:

```
set("Necropotency") and cp() == 160 and traittype("divine", "infused")
```
### Example 2 - **Use FCO Item Saver's api**

Items matched by:

* Marked as Gear1 in FCO Item Saver
Rule:

```
ismarked("gear_1")
```
### Example 3 - **Exclude Conditions (Using 'not')**

Items matched by:

* Item is armor type
* Item is for research
* Item trait is not Divines or Infused
```
type("armor") and keepresearch() and not traittype("armor_infused", "armor_divines")
```
### Example 4 - **Enhanced Deconstruct**

This rule combines several different ways that an item can be included in this group, combining base ESO information with addon integrations for FCOItemSaver, ItemSaver, and SetTracker. Note that you do not have to have all (or even any of these addons installed) for this rule to work. 

If for instance you do not have SetTracker installed, then the `istracked()` function provided by the AutoCategory-SetTracker integration will always return false so that it falls to the rest of your rule to match with an item.

Items matched by:
* Item `traittype` is intricate, or
* Item is marked for deconstruction by **ItemSaver** (using `ismarkedis()`), or
* Item is marked for deconstruction by **FCOIS** (using `ismarked()`), or
* Item is tracked by **SetTracker** (using `istracked()`) for "Sell/Decon", or
* Item matches both:
  * Item is either of type armor or weapon, and
  * Item does not belong to any set
* Item matches both:
  * Item's equipment type is either "head" or "shoulders", and
  * Item does not belong to a monster set

```
traittype("intricate") or ismarkedis("Decon") or ismarked("deconstruction")
 or istracked("Sell/Decon") or (type("armor","weapon") and not isset()) 
 or (equiptype("head","shoulders") and not ismonsterset())
```


--------------------------------------------------------------

### Example 5 - **Repair Kits**

This rule is a bit tricky because of the way that the oldest standard repair kits were categorized in the game (and how lockpicks were also categorized).

Standard repair kits and lockpicks were both categorized in the original game as type() "tool". So to look for both standard repair and crown repair kits, you would think that you could use:
```
type("tool","crown_repair")
```
but this will also include lockpicks (the other tool). So we modify the rule to specifically exclude lockpicks as below:

```
type("tool","crown_repair") and not islockpick()
```


--------------------------------------------------------------

_**Acknowledgement: Page is based on the older version by Rockingdice**_