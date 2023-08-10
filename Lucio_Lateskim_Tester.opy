settings {
    "main": {
        "description": "A workshop code to practice lucio late jumps\nAlso includes a bot to execute a late jump based on a set number of ticks\nShare Code: Y4A9A",
        "modeName": "Lucio Late Jump Trainer and Bot"
    },
    "gamemodes": {
        "skirmish": {
            "enabledMaps": [
                "workshopChamber"
            ]
        }
    },
    "heroes": {
        "allTeams": {
            "enabledHeroes": [
                "lucio"
            ]
        }
    }
}

# Global Variables
## Global Menu Variables
### Colors
globalvar default_menu_label_color
globalvar default_menu_off_index_color
globalvar default_menu_on_index_color
globalvar data_loaded

globalvar bot_exec
## Demonstartion Variables

# Player Variables
## Player Menu Variables
### General Menu Variables
playervar menu_visible
playervar item_visible
playervar menu_index
playervar menu_input
playervar menu_max_pos
playervar menu_do_off_actions
playervar menu_wait
### Menu Label Variables
playervar menu_label_size
playervar menu_label
playervar menu_label_color
### Menu Option Variables
playervar menu_opt_size
playervar menu_off_opt_title
playervar menu_on_opt_title
playervar menu_opt_var
playervar menu_opt_status
playervar menu_opt_len
playervar menu_off_opt_color
playervar menu_on_opt_color
playervar menu_opt_value
### Bar Variables
playervar bar_title
playervar bar_var
playervar bar_color
### Submenu Variables
playervar submenu_start_index
playervar submenu_index
playervar sub_size
playervar menu_substart_value
## Demonstation Variables
playervar demo_cycle_menu_index
playervar demo_cycle_menu_status

#Subroutine Names
## Menu Defaults
subroutine default_menu_variables
## Menu Toggle actions
subroutine menu_off_actions
## Menu Prompt
subroutine create_settings_prompt
## Menu Labels
subroutine increment_for_menu_label
subroutine new_menu_label_header
subroutine new_menu_label_subtext
## Menu Items
subroutine increment_for_menu_item
subroutine new_menu_item_selection
subroutine new_menu_item_toggle
subroutine new_menu_item_cycle
subroutine new_menu_item_cycle_bar
## Submenu
subroutine increment_for_submenu_item
## Menu Actions
subroutine menu_act_set_position
subroutine menu_act_toggle_bot
subroutine menu_act_cycle_walk_tick
subroutine menu_act_cycle_wallride_tick
subroutine menu_act_cycle_latejump_tick
subroutine menu_action_open_submenu
subroutine menu_action_close_submenu
subroutine menu_up_check
subroutine menu_down_check


rule "Rules with (O - ) should be copied, rules with (X - ) are used for demonstration or irrelevent.":

    # I'm going to try my best to comment out every piece of code so that it's easier to understand. If you have any questions let me know on my discord: discord.gg/YPQ5ETNT45
    smallMessage(hostPlayer, "hi")


rule "Initialize Global Menu Variables (O - copy this, set the colors to the colors you want your menu to be by default you can also change the selection color per menu item in the generate rule)":

    # We use a flag so that the rule that generates the menu waits until the default variables are initialized. It shouldn't matter for rules this small but as complexity increases you can run bugs due to race conditions.
    data_loaded = false
    # Here we define what the default colors are for our menu.
    # In this case our labels will be white.
    default_menu_label_color = Color.WHITE
    # When the cursor is not on an item on the menu the text will be white.
    default_menu_off_index_color = Color.WHITE
    # When the cursor is on an item on the menu the text will be orange.
    default_menu_on_index_color = Color.ORANGE
    # Set the flag to true so that the menu can be generated.
    data_loaded = true


# UI Elements
rule "Menu Controls: Toggle Menu with Interact (O - used to toggle the menu on and off)":
    @Event eachPlayer
    @Team 1
    # Change this condition to whatever button(s) you want to trigger the main menu. 
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    if bot_exec == true:
        smallMessage(hostPlayer, "wait for bot to finish")
        waitUntil(bot_exec == false,9999)
    # A toggle for the menu_visible flag
    if eventPlayer.menu_visible == true:
        eventPlayer.menu_visible = false
    else:
        eventPlayer.menu_visible = true


rule "Menu Controls: Toggle On Setup (O - disables players inputs from causing things to happen in games)":
    @Event eachPlayer
    @Team 1
    # Here we disable the players inputs set their movement speed to zero so that their inputs don't affect the their hero while in the menu.
    @Condition eventPlayer.menu_visible == true

    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.JUMP)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.disallowButton(Button.ULTIMATE)
    eventPlayer.setMoveSpeed(0)


rule "Menu Controls: Toggle Off Setup (O - enables player inputs so they can interact with the game)":
    @Event eachPlayer
    @Team 1
    # Here we re-enable the players inputs.
    @Condition eventPlayer.menu_visible == false

    # If you want to use additional stuff when closing the menu I recommend doing that in another rule since the user may toggle the menu open again while this rule is running causing bugs.
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    # Also if your game mode disallows certain inputs, remove those inputs from this action list.
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.allowButton(Button.JUMP)
    eventPlayer.allowButton(Button.ABILITY_1)
    eventPlayer.allowButton(Button.ABILITY_2)
    eventPlayer.allowButton(Button.ULTIMATE)
    eventPlayer.setMoveSpeed(100)


rule "Menu Controls: Up Scroll (O - used to scroll up the menu)":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.menu_visible == true
    # We use the player's movement keys to navigate the menu.
    # If you'd like to use a button input instead, change this condition.
    @Condition eventPlayer.getThrottle() == Vector.FORWARD
    
    # This check moves the menu "cursor" up and moves to the end of the menu if the last index was at the start.
    menu_up_check() 
    # We have this loop since this framework supports hiding menu items.
    while eventPlayer.item_visible[eventPlayer.menu_index] == false:
        menu_up_check()


rule "Menu Controls: Down Scroll (O - used to scroll down the menu)":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.menu_visible == true
    # We use the player's movement keys to navigate the menu.
    # If you'd like to use a button input instead, change this condition.
    @Condition eventPlayer.getThrottle() == Vector.BACKWARD
    
    # This check moves the menu "cursor" down and moves to the start of the menu if the last index was at the end.
    menu_down_check()
    # We have this loop since this framework supports hiding menu items. 
    while eventPlayer.item_visible[eventPlayer.menu_index] == false:
        menu_down_check()


def menu_up_check():
    @Name "SUB: menu_up_check (O - used to scroll up the menu)"

    # If the menu index is equal to the start of the submenu start location
    if eventPlayer.menu_index - eventPlayer.submenu_start_index[eventPlayer.submenu_index] <= 0:
        # then set the index to the end of the submenu
        eventPlayer.menu_index = eventPlayer.submenu_start_index[eventPlayer.submenu_index+1] - 1
    # else move up 1 on the menu.
    else:  
        eventPlayer.menu_index -= 1


def menu_down_check():
        @Name "SUB: menu_down_check (O - used to scroll down the menu)"    

    # If the menu index is equal to the end of our submenu
    if eventPlayer.menu_index >= eventPlayer.submenu_start_index[eventPlayer.submenu_index+1] - 1:
        # then set the index to the start of the submenu
        eventPlayer.menu_index = eventPlayer.submenu_start_index[eventPlayer.submenu_index]
    # else move down 1 on the menu.
    else:
        eventPlayer.menu_index += 1


def default_menu_variables():
    @Name "SUB: default_menu_variables (O - Defaults all the menu variables for menu init)"

    # Menu index is the index the players menu "cursor" is currently on. Menus and submenus use this variable to navigate.
    eventPlayer.menu_index = 0
    # Submenu index is a variable that keeps track of what submenu the player is on. You can create multiple submenus and select which one to show using this variable.
    eventPlayer.submenu_index = 0
    # The way the submenu system works is that the values that menu_index is set to are subdivided based on the submenu. So for menu 0 the menu_index will be 0, but for menu 1 the menu_index will be 10, for example.
    eventPlayer.submenu_start_index[0] = 0
    # We use the next index of the submenu for some checks so we always want + 1 submenu array items, this will be set to the end of the last submenu + 1
    eventPlayer.submenu_start_index[1] = 1
    # This is an index used to determine the position of the hud text we make, this is incremented for both labels and menu items.
    eventPlayer.menu_max_pos = -1
    # This is used to track the last menu label created.
    eventPlayer.menu_label_size = -1
    # This is used to track the last menu item created.
    eventPlayer.menu_opt_size = -1
    # This is used to track the last menu submenu created.
    eventPlayer.sub_size = 0
    # This the default off color. This framework doesn't support different colors for off_index menu items, but it shouldn't be hard to implement
    eventPlayer.menu_off_opt_color = default_menu_off_index_color


def create_settings_prompt():
    @Name "SUB: create_settings_prompt (O - copy this if you want the same settings prompt on the left side of the screen)"
    # Settings Headers
    hudSubheader([i for i in eventPlayer if not eventPlayer.menu_visible], 
    "\nPress  {0}  for menu / help".format(buttonString(Button.INTERACT)), HudPosition.LEFT, 1000, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visible], 
    "\nPress  {0}  to close menu".format(buttonString(Button.INTERACT)), HudPosition.LEFT, 1001, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visible], 
    # Remember to change these if you change the controls
    "—  Controls  —", HudPosition.LEFT, 1002, Color.BLACK, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visible], 
    "Select: {0}".format(buttonString(Button.ABILITY_2)), HudPosition.LEFT, 1003, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visible], 
    "Menu Up: Forward (W)", HudPosition.LEFT, 1004, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visible], 
    "Menu Down: Backward (S)", HudPosition.LEFT, 1005, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visible], 
    "Small Step: left / right (A / D)", HudPosition.LEFT, 1006, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visible], 
    "Large Step: {0} / {1}".format(buttonString(Button.ULTIMATE), buttonString(Button.ABILITY_2)), HudPosition.LEFT, 1007, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


def increment_for_menu_label():
    @Name "SUB: increment_menu_label (O - this increments all the variables needed when creating a new menu label.)"

    eventPlayer.menu_label_size += 1
    eventPlayer.menu_max_pos += 1
    eventPlayer.item_visible[eventPlayer.menu_label_size] = true


def increment_for_menu_item():
    @Name "SUB: increment_for_menu_item (O - this increments all the variables needed when creating a new menu item.)"

    eventPlayer.menu_opt_size += 1
    eventPlayer.menu_max_pos += 1
    eventPlayer.submenu_start_index[eventPlayer.sub_size+1] = eventPlayer.menu_opt_size+1
    eventPlayer.item_visible[eventPlayer.menu_opt_size] = true


def increment_for_submenu_item():
    @Name "SUB: increment_for_new_submenu (O - this increments all the variables needed when creating a new submenu.)"

    eventPlayer.sub_size += 1
    eventPlayer.menu_max_pos = -1


def new_menu_label_header():
    @Name "SUB: new_menu_label_header (O - this is header text that you can use to help organize your menu)"

    hudHeader([i for i in eventPlayer if eventPlayer.menu_visible and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)], 
    "{0}".format(eventPlayer.menu_label[evalOnce(eventPlayer.menu_label_size)]),
    HudPosition.TOP,
    evalOnce(eventPlayer.menu_max_pos),
    eventPlayer.menu_label_color[evalOnce(eventPlayer.menu_label_size)],
    HudReeval.VISIBILITY_STRING_AND_COLOR,
    SpecVisibility.DEFAULT)


def new_menu_label_subtext():
    @Name "SUB: new_menu_label_subtext (O - this is subheader text that I used to provide extra info at the bottom of the menu)"

    hudSubtext([i for i in eventPlayer if eventPlayer.menu_visible and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)], 
    "{0}".format(eventPlayer.menu_label[evalOnce(eventPlayer.menu_label_size)]),
    HudPosition.TOP,
    evalOnce(eventPlayer.menu_max_pos),
    eventPlayer.menu_label_color[evalOnce(eventPlayer.menu_label_size)],
    HudReeval.VISIBILITY_STRING_AND_COLOR,
    SpecVisibility.DEFAULT)
    

def new_menu_item_selection():
    @Name "SUB: new_menu_item_selection (O - this a menu item with only the menu item title and not variable text.)"

    # Case: index off
    hudSubheader(
    [i for i in eventPlayer if eventPlayer.menu_visible 
        and eventPlayer.menu_index != evalOnce(eventPlayer.menu_opt_size) 
        and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)
        and eventPlayer.item_visible[evalOnce(eventPlayer.menu_opt_size)] == true], 
    "{0}".format(eventPlayer.menu_off_opt_title[evalOnce(eventPlayer.menu_opt_size)]),
    HudPosition.TOP,
    evalOnce(eventPlayer.menu_max_pos),
    eventPlayer.menu_off_opt_color,
    HudReeval.VISIBILITY_STRING_AND_COLOR,
    SpecVisibility.DEFAULT)
    # Case: index on
    hudSubheader(
    [i for i in eventPlayer if eventPlayer.menu_visible 
        and eventPlayer.menu_index == evalOnce(eventPlayer.menu_opt_size) 
        and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)
        and eventPlayer.item_visible[evalOnce(eventPlayer.menu_opt_size)] == true],
    "■  {0}".format(eventPlayer.menu_on_opt_title[evalOnce(eventPlayer.menu_opt_size)]),
    HudPosition.TOP,
    evalOnce(eventPlayer.menu_max_pos),
    eventPlayer.menu_on_opt_color[evalOnce(eventPlayer.menu_opt_size)],
    HudReeval.VISIBILITY_STRING_AND_COLOR,
    SpecVisibility.DEFAULT)


def new_menu_item_toggle():
    @Name "SUB: new_menu_item_toggle (O - this a menu item with 2 variables, the title and the optional variable)"

    # Case: index off
    hudSubheader(
    [i for i in eventPlayer if eventPlayer.menu_visible 
        and eventPlayer.menu_index != evalOnce(eventPlayer.menu_opt_size) 
        and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)
        and eventPlayer.item_visible[evalOnce(eventPlayer.menu_opt_size)] == true], 
    "{0}".format(eventPlayer.menu_off_opt_title[evalOnce(eventPlayer.menu_opt_size)]),
    HudPosition.TOP,
    evalOnce(eventPlayer.menu_max_pos),
    eventPlayer.menu_off_opt_color,
    HudReeval.VISIBILITY_STRING_AND_COLOR,
    SpecVisibility.DEFAULT)

    # Case: index on, see menu_act_toggle to see how to update the menu_opt_var string.
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visible 
        and eventPlayer.menu_index == evalOnce(eventPlayer.menu_opt_size) 
        and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)
        and eventPlayer.item_visible[evalOnce(eventPlayer.menu_opt_size)] == true],
    "■  {0}{1}".format(eventPlayer.menu_on_opt_title[evalOnce(eventPlayer.menu_opt_size)], eventPlayer.menu_opt_var[evalOnce(eventPlayer.menu_opt_size)]), 
    HudPosition.TOP,
    evalOnce(eventPlayer.menu_max_pos),
    eventPlayer.menu_on_opt_color[evalOnce(eventPlayer.menu_opt_size)],
    HudReeval.VISIBILITY_STRING_AND_COLOR,
    SpecVisibility.DEFAULT)


def new_menu_item_cycle():
    @Name "SUB: new_menu_item_cycle (O - Don't copy if you don't need it. this is similar to the toggle but it has ←  {1}  → surrounding the optional variable, I needed to use this type of menu item very often so it's its own option.)"

    # Case: index off
    hudSubheader(
    [i for i in eventPlayer if eventPlayer.menu_visible
        and eventPlayer.menu_index != evalOnce(eventPlayer.menu_opt_size) 
        and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)
        and eventPlayer.item_visible[evalOnce(eventPlayer.menu_opt_size)] == true], 
    "{0}".format(eventPlayer.menu_off_opt_title[evalOnce(eventPlayer.menu_opt_size)]),
    HudPosition.TOP, 
    evalOnce(eventPlayer.menu_max_pos), 
    eventPlayer.menu_off_opt_color, 
    HudReeval.VISIBILITY_STRING_AND_COLOR, 
    SpecVisibility.DEFAULT)

    # Case: index on, see menu_act_cycle to see how to update the menu_opt_var string.
    hudSubheader(
    [i for i in eventPlayer if eventPlayer.menu_visible 
        and eventPlayer.menu_index == evalOnce(eventPlayer.menu_opt_size) 
        and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)
        and eventPlayer.item_visible[evalOnce(eventPlayer.menu_opt_size)] == true], 
    "■ {0} ←  {1}  → ".format(eventPlayer.menu_on_opt_title[evalOnce(eventPlayer.menu_opt_size)], eventPlayer.menu_opt_var[evalOnce(eventPlayer.menu_opt_size)]),
    HudPosition.TOP, 
    evalOnce(eventPlayer.menu_max_pos), 
    eventPlayer.menu_on_opt_color[evalOnce(eventPlayer.menu_opt_size)], 
    HudReeval.VISIBILITY_STRING_AND_COLOR, 
    SpecVisibility.DEFAULT)


def new_menu_item_cycle_bar():
    @Name "SUB: new_menu_item_cycle_bar (O - Don't copy if you don't need it. This is a niche menu item I made to select from hero icons since header text is larger which makes it easier for the player to see.)"

    # Case: index off
    hudSubheader(
    [i for i in eventPlayer if eventPlayer.menu_visible 
        and eventPlayer.menu_index != evalOnce(eventPlayer.menu_opt_size) 
        and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)
        and eventPlayer.item_visible[evalOnce(eventPlayer.menu_opt_size)] == true], 
    "{0}".format(eventPlayer.menu_off_opt_title[evalOnce(eventPlayer.menu_opt_size)]), 
    HudPosition.TOP, 
    evalOnce(eventPlayer.menu_max_pos), 
    eventPlayer.menu_off_opt_color, 
    HudReeval.VISIBILITY_STRING_AND_COLOR, 
    SpecVisibility.DEFAULT)

    # Case: index on, see menu_act_cycle_bar to see how to update the menu_opt_var string.
    hudSubheader(
    [i for i in eventPlayer if eventPlayer.menu_visible 
        and eventPlayer.menu_index == evalOnce(eventPlayer.menu_opt_size) 
        and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)
        and eventPlayer.item_visible[evalOnce(eventPlayer.menu_opt_size)] == true], 
    "■  {0}  {1}".format(eventPlayer.menu_on_opt_title[evalOnce(eventPlayer.menu_opt_size)], eventPlayer.menu_opt_var[evalOnce(eventPlayer.menu_opt_size)]), 
    HudPosition.TOP, 
    evalOnce(eventPlayer.menu_max_pos), 
    eventPlayer.menu_on_opt_color[evalOnce(eventPlayer.menu_opt_size)], 
    HudReeval.VISIBILITY_STRING_AND_COLOR, 
    SpecVisibility.DEFAULT)

    # Increment Menu Position
    eventPlayer.menu_max_pos += 1

    # Submenu hudheader
    hudHeader(
    [i for i in eventPlayer if eventPlayer.menu_visible 
    and eventPlayer.menu_index == evalOnce(eventPlayer.menu_opt_size) 
    and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)
    and eventPlayer.item_visible[evalOnce(eventPlayer.menu_opt_size)] == true], 
    "{0} ←  {1}  →".format(eventPlayer.bar_title[eventPlayer.menu_index], eventPlayer.bar_var[eventPlayer.menu_index]), 
    HudPosition.TOP, 
    evalOnce(eventPlayer.menu_max_pos), 
    eventPlayer.bar_color[evalOnce(eventPlayer.menu_opt_size)], 
    HudReeval.VISIBILITY_STRING_AND_COLOR, 
    SpecVisibility.DEFAULT)

    
globalvar walk_tick
globalvar wallride_tick
globalvar latejump_tick
globalvar bot_mode
globalvar default_position
globalvar default_facing

rule "generate host menu":
    @Event eachPlayer
    # Here we generate a menu specifically for the host player, you can also make specific menus based on a players hero or role, for example.
    @Condition eventPlayer == hostPlayer

    waitUntil(data_loaded == true, 9999)
    # Default the menu variables used to navigate the menu.
    default_menu_variables()
    # Create the prompt of the left hand side of the screen that explains the settings.
    create_settings_prompt()

    # Our first menu label. This is the header of the menu, since it is first, later well add another label in the middle.
    increment_for_menu_label()
    # This sets the text of the menu label to "Host Menu"
    eventPlayer.menu_label[eventPlayer.menu_label_size] = "Menu"
    # This sets the menu color to the default
    eventPlayer.menu_label_color[eventPlayer.menu_label_size] = default_menu_label_color
    new_menu_label_header()

    increment_for_menu_item()
    eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size] = "Bot Mode"
    eventPlayer.menu_on_opt_title[eventPlayer.menu_opt_size] = "Bot Mode: "
    eventPlayer.menu_opt_var[eventPlayer.menu_opt_size] = "Off"
    eventPlayer.menu_on_opt_color[eventPlayer.menu_opt_size] = default_menu_on_index_color
    eventPlayer.menu_opt_status[eventPlayer.menu_opt_size] = null
    new_menu_item_toggle()

    increment_for_menu_item()
    eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size] = "Set Position"
    eventPlayer.menu_on_opt_title[eventPlayer.menu_opt_size] = eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size]
    eventPlayer.menu_on_opt_color[eventPlayer.menu_opt_size] = default_menu_on_index_color
    eventPlayer.menu_opt_status[eventPlayer.menu_opt_size] = null
    new_menu_item_selection()

    increment_for_menu_item()
    eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size] = "Walk Tick"
    eventPlayer.menu_on_opt_title[eventPlayer.menu_opt_size] = ""
    eventPlayer.menu_opt_var[eventPlayer.menu_opt_size] = walk_tick
    eventPlayer.menu_on_opt_color[eventPlayer.menu_opt_size] = default_menu_on_index_color
    eventPlayer.menu_opt_status[eventPlayer.menu_opt_size] = 0
    eventPlayer.menu_opt_len[eventPlayer.menu_opt_size] = 100
    new_menu_item_cycle()

    increment_for_menu_item()
    eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size] = "Wallride Tick"
    eventPlayer.menu_on_opt_title[eventPlayer.menu_opt_size] = ""
    eventPlayer.menu_opt_var[eventPlayer.menu_opt_size] = wallride_tick
    eventPlayer.menu_on_opt_color[eventPlayer.menu_opt_size] = default_menu_on_index_color
    eventPlayer.menu_opt_status[eventPlayer.menu_opt_size] = 0
    eventPlayer.menu_opt_len[eventPlayer.menu_opt_size] = 100
    new_menu_item_cycle()

    increment_for_menu_item()
    eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size] = "latejump Tick"
    eventPlayer.menu_on_opt_title[eventPlayer.menu_opt_size] = ""
    eventPlayer.menu_opt_var[eventPlayer.menu_opt_size] = latejump_tick
    eventPlayer.menu_on_opt_color[eventPlayer.menu_opt_size] = default_menu_on_index_color
    eventPlayer.menu_opt_status[eventPlayer.menu_opt_size] = 0
    eventPlayer.menu_opt_len[eventPlayer.menu_opt_size] = 100
    new_menu_item_cycle()

# Player Menu
rule "Menu Actions: Input Read":
    @Event eachPlayer
    @Condition eventPlayer.menu_visible == true
    @Condition (eventPlayer.isHoldingButton(Button.ULTIMATE) == true or eventPlayer.isHoldingButton(Button.ABILITY_2) == true or eventPlayer.getThrottle() == Vector.LEFT or eventPlayer.getThrottle() == Vector.RIGHT)
    
    # We use the player variable menu_input to tell the subroutines we call that the player inputed one of our selection keys.
    if eventPlayer.getThrottle() == Vector.LEFT:
        eventPlayer.menu_input = -1
    elif eventPlayer.getThrottle() == Vector.RIGHT:
        eventPlayer.menu_input = 1
    elif eventPlayer.isHoldingButton(Button.ABILITY_2):
        eventPlayer.menu_input = 0
    else:
        eventPlayer.menu_input = -2

    eventPlayer.menu_substart_value = eventPlayer.submenu_start_index[eventPlayer.submenu_index]
    eventPlayer.menu_opt_value = eventPlayer.menu_opt_status[eventPlayer.menu_index]
    eventPlayer.menu_wait = 0.1

    if eventPlayer.submenu_index == 0:
        if eventPlayer.menu_index == 0 + eventPlayer.menu_substart_value:
            menu_act_toggle_bot()
        elif eventPlayer.menu_index == 1 + eventPlayer.menu_substart_value:
            menu_act_set_position()
        elif eventPlayer.menu_index == 2 + eventPlayer.menu_substart_value:
            menu_act_cycle_walk_tick()
        elif eventPlayer.menu_index == 3 + eventPlayer.menu_substart_value:
            menu_act_cycle_wallride_tick()
        elif eventPlayer.menu_index == 4 + eventPlayer.menu_substart_value:
            menu_act_cycle_latejump_tick()


## Menu Actions 

def menu_act_toggle_bot():
    @Name "SUB: menu_act_toggle_bot"

    bot_mode = not bot_mode
    if bot_mode == true:
        eventPlayer.menu_opt_var[eventPlayer.menu_index] = "on"
    else:
        eventPlayer.menu_opt_var[eventPlayer.menu_index] = "off"


def menu_act_set_position():
    @Name "SUB: menu_act_set_position"

    default_position = eventPlayer.getPosition()
    default_facing = eventPlayer.getFacingDirection()
    smallMessage(eventPlayer, default_position)
    smallMessage(eventPlayer, default_facing)
    

def menu_act_cycle_walk_tick():
    @Name "SUB: menu_act_cycle_wallride_tick"

    if eventPlayer.menu_input == -2:
        walk_tick -= 10
    elif eventPlayer.menu_input == -1:
        walk_tick -= 1
    elif eventPlayer.menu_input == 1:
        walk_tick += 1
    else:
        walk_tick += 10
    if walk_tick < 0:
        walk_tick = 100
    if walk_tick > 100:
        walk_tick = 0
    eventPlayer.menu_opt_var[eventPlayer.menu_index] = walk_tick


def menu_act_cycle_wallride_tick():
    @Name "SUB: menu_act_cycle_wallride_tick"

    if eventPlayer.menu_input == -2:
        wallride_tick -= 10
    elif eventPlayer.menu_input == -1:
        wallride_tick -= 1
    elif eventPlayer.menu_input == 1:
        wallride_tick += 1
    else:
        wallride_tick += 10
    if wallride_tick < 0:
        wallride_tick = 100
    if wallride_tick > 100:
        wallride_tick = 0
    eventPlayer.menu_opt_var[eventPlayer.menu_index] = wallride_tick


def menu_act_cycle_latejump_tick():
    @Name "SUB: menu_act_cycle_latejump_tick"

    if eventPlayer.menu_input == -2:
        latejump_tick -= 10
    elif eventPlayer.menu_input == -1:
        latejump_tick -= 1
    elif eventPlayer.menu_input == 1:
        latejump_tick += 1
    else:
        latejump_tick += 10
    if latejump_tick < 0:
        latejump_tick = 100
    if latejump_tick > 100:
        latejump_tick = 0
    eventPlayer.menu_opt_var[eventPlayer.menu_index] = latejump_tick

rule "timing message":
    @Event playerJoined

    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visible == true], "\nPress R to reset your position\n\nTo late jump press jump\nless than 0.22s (14 ticks)\nafter releasing from a wall\n", HudPosition.RIGHT, 1000, Color.BLACK, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visible == true], "Late Jump Successful ", HudPosition.RIGHT, 1001, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visible == true], "Late Jump Too Late", HudPosition.RIGHT, 1001, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visible == true], "Late Jump Not Attempted", HudPosition.RIGHT, 1001, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    #hudSubheader(eventPlayer, "Load (Curr/Avg/Peak):  {0}  /  {1}  /  {2}".format(getServerLoad(),getAverageServerLoad(),getPeakServerLoad()), HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    

globalvar bot_player
globalvar enter_speed
globalvar landing_speed
globalvar data_array_size
globalvar wallride_time_array
globalvar latejump_time_array
globalvar time_color_array
globalvar latejump_timer
globalvar bot_mode_camera_lock
globalvar y_max



subroutine set_position
subroutine reset_position
subroutine bot_action
subroutine visual_update
subroutine lucio_bot_ai

    
rule "workshop settings init":


    walk_tick = createWorkshopSetting(int[0:100], "0. Bot Mode", "Bot Walking Ticks", 50, 0)
    wallride_tick = createWorkshopSetting(int[0:100], "0. Bot Mode", "Bot Wallriding Ticks", 10, 1)
    latejump_tick = createWorkshopSetting(int[0:100], "0. Bot Mode", "Bot latejump Ticks", 10, 2)
    bot_mode_camera_lock = createWorkshopSetting(bool, "0. Bot Mode", "Bot Mode Camera Lock", true, 3)

    default_position = vect(createWorkshopSetting(float[-999:999], "1. Default Position", "x coord", 19.5, 0),
    createWorkshopSetting(float[-999:999], "1. Default Position", "y coord", 0, 1),
    createWorkshopSetting(float[-999:999], "1. Default Position", "z coord", 19.5, 2))
    default_facing = vect(createWorkshopSetting(float[-999:999], "2. Default Facing", "x coord", -1, 0),
    createWorkshopSetting(float[-999:999], "2. Default Facing", "y coord", 0, 1),
    createWorkshopSetting(float[-999:999], "2. Default Facing", "z coord", 0, 2))
    

rule "var init":

    bot_mode = false
    wallride_time_array[0] = "0.00 (0)"
    latejump_time_array[0] = "0.00 (0)"
    wallride_time_array[1] = "0.00 (0)"
    latejump_time_array[1] = "0.00 (0)"
    wallride_time_array[2] = "0.00 (0)"
    latejump_time_array[2] = "0.00 (0)"
    wallride_time_array[3] = "0.00 (0)"
    latejump_time_array[3] = "0.00 (0)"
    wallride_time_array[4] = "0.00 (0)"
    latejump_time_array[4] = "0.00 (0)"
    wallride_time_array[5] = "0.00 (0)"
    latejump_time_array[5] = "0.00 (0)"

    time_color_array[0] = Color.BLACK
    time_color_array[1] = Color.BLACK
    time_color_array[2] = Color.BLACK
    time_color_array[3] = Color.BLACK
    time_color_array[4] = Color.BLACK

rule "slot 0 joined":
    @Event playerJoined
    @Slot 0

    bot_player = getPlayersInSlot(0, Team.1)


rule "hudtexts":
    @Event playerJoined

    hudSubheader(eventPlayer, "Current Speed: {0}".format(bot_player.getSpeed()), HudPosition.TOP, 0, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([i for i in eventPlayer if bot_mode == true], "-- Bot Settings --", HudPosition.LEFT, 10, Color.BLACK, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if bot_mode == true], "Walk Ticks: {0}".format(walk_tick), HudPosition.LEFT, 11, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if bot_mode == true], "Wallride Ticks: {0}".format(wallride_tick), HudPosition.LEFT, 12, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if bot_mode == true], "latejump Ticks: {0}".format(latejump_tick), HudPosition.LEFT, 13, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(eventPlayer, "-----", HudPosition.LEFT, 20, Color.BLACK, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(eventPlayer, "WR End Speed: {0}".format(enter_speed), HudPosition.LEFT, 21, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(eventPlayer, "LJ Max Speed: {0}".format(landing_speed), HudPosition.LEFT, 22, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(eventPlayer, "Y-axis Max Speed: {0}".format(y_max), HudPosition.LEFT, 23, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

    hudSubtext(eventPlayer, "-----", HudPosition.LEFT, 30, Color.BLACK, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

    hudSubtext(eventPlayer, "Timing Data", HudPosition.RIGHT, 10, Color.BLACK, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(eventPlayer, "|  WR Time (Ticks)  |  LJ Time (Ticks)  |", HudPosition.RIGHT, 11, Color.BLACK, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(eventPlayer, "          {0}         |        {1}          ".format(wallride_time_array[0], latejump_time_array[0]), HudPosition.RIGHT, 12, time_color_array[0], HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    hudSubheader(eventPlayer, "          {0}         |        {1}          ".format(wallride_time_array[1], latejump_time_array[1]), HudPosition.RIGHT, 13, time_color_array[1], HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    hudSubheader(eventPlayer, "          {0}         |        {1}          ".format(wallride_time_array[2], latejump_time_array[2]), HudPosition.RIGHT, 14, time_color_array[2], HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    hudSubheader(eventPlayer, "          {0}         |        {1}          ".format(wallride_time_array[3], latejump_time_array[3]), HudPosition.RIGHT, 15, time_color_array[3], HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    hudSubheader(eventPlayer, "          {0}         |        {1}          ".format(wallride_time_array[4], latejump_time_array[4]), HudPosition.RIGHT, 16, time_color_array[4], HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    

rule "player/bot init":
    @Event eachPlayer
    @Slot 0
    @Condition eventPlayer.hasSpawned() == true

    #eventPlayer.teleport(default_position)


rule "bot mode exec":
    @Condition hostPlayer.menu_visible == false
    @Condition bot_mode == true

    bot_exec = true
    lucio_bot_ai()
    bot_exec = false
    wait(1)

    if RULE_CONDITION:
        goto RULE_START
    

def lucio_bot_ai():
    @Name "SUB: lucio_bot_ai"

    bot_player.teleport(default_position)
    bot_player.startFacing(default_facing, 9999,Relativity.TO_WORLD,FacingReeval.NONE)
    wait(0.5)
    if bot_mode_camera_lock == false:
        bot_player.stopFacing()
    wait(1)
    smallMessage(hostPlayer, "  start")
    bot_player.startThrottleInDirection(Vector.FORWARD, 1, Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    wait(0.016 * walk_tick)
    bot_player.startForcingButton(Button.JUMP)
    wait(0.016 * wallride_tick)
    bot_player.stopForcingButton(Button.JUMP)
    wait(0.016 * latejump_tick)
    bot_player.forceButtonPress(Button.JUMP)
    wait(1)

    bot_player.stopThrottleInDirection()
    bot_player.stopFacing()

    smallMessage(hostPlayer, "  stop")

rule "latejump watcher":
    @Event eachPlayer
    @Slot 0

    time_color_array[4] = time_color_array[3]
    time_color_array[3] = time_color_array[2]
    time_color_array[2] = time_color_array[1]
    time_color_array[1] = time_color_array[0]

    wallride_time_array[4] = wallride_time_array[3]
    wallride_time_array[3] = wallride_time_array[2]
    wallride_time_array[2] = wallride_time_array[1]
    wallride_time_array[1] = wallride_time_array[0]

    latejump_time_array[4] = latejump_time_array[3]
    latejump_time_array[3] = latejump_time_array[2]
    latejump_time_array[2] = latejump_time_array[1]
    latejump_time_array[1] = latejump_time_array[0]

    time_color_array[0] = Color.YELLOW
    wallride_time_array[0] = "......"
    latejump_time_array[0] = "......"
    latejump_timer = 0

    waitUntil(eventPlayer.isHoldingButton(Button.JUMP) == true, 9999)
    chase(latejump_timer, 10, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    waitUntil(eventPlayer.isHoldingButton(Button.JUMP) == false, 9999)
    wallride_time_array[0] = "{0}s ({1})".format(latejump_timer, round(latejump_timer / 0.016))
    latejump_timer = 0
    enter_speed = eventPlayer.getSpeed()
    waitUntil(eventPlayer.isOnGround() or eventPlayer.isHoldingButton(Button.JUMP) == true, 9999)
    stopChasingVariable(latejump_timer)
    latejump_time_array[0] = "{0}s ({1})".format(latejump_timer, round(latejump_timer / 0.016))
    if eventPlayer.isOnGround() == false:
        landing_speed = eventPlayer.getSpeed()
        if round(latejump_timer / 0.016) < 14:
            time_color_array[0] = Color.GREEN
        else:
            time_color_array[0] = Color.ORANGE
    else:
        time_color_array[0] = Color.RED
    waitUntil(eventPlayer.isHoldingButton(Button.JUMP) == false or eventPlayer.isOnGround() == true, 9999)

    if RULE_CONDITION:
        goto RULE_START


rule "position reset":
    @Event eachPlayer
    @Slot 0
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true

    eventPlayer.teleport(default_position)
    bot_player.startFacing(default_facing, 9999,Relativity.TO_WORLD,FacingReeval.NONE)
    wait(0.1)
    bot_player.stopFacing()


rule "y max reset":
    @Event eachPlayer
    @Slot 0

    wait(1)
    y_max = 0

    if RULE_CONDITION:
        goto RULE_START

rule "y max set":
    @Event eachPlayer
    @Slot 0

    wait()
    if y_max < eventPlayer.getVelocity().y:
        y_max = eventPlayer.getVelocity().y
    if RULE_CONDITION:
        goto RULE_START