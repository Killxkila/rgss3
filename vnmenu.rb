#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ VN Interaction Menu v. 1.0 (04-13-2016)
#║ by Fiona Morella & Ryan Canteras
#║ rymakesgames.wordpress.com | rycanteras@gmail.com
#║ 
#║ Creates a visual novel-style menu for interacting with the environment
#║ or conversing with NPCs by pulling all relevant events on the map and
#║ listing them as window_command items. Great for people who want to map
#║ as little as possible. And visual novels.
#║ 
#║ • For commercial and non-commercial use. Credit greatly appreciated.
#║
#║ • Hit us up if you use it in your game! We'd love to try it out.
#║
#║ • For inquiries, bug reports and feature suggestions, contact sabao
#║   on the script's thread on rpgmakerweb.com or rymakesgames.wordpress.com
#╚═=═=════════════════════════════════════════════════════════════════════════=#

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ HOW TO CALL THE MENU THROUGH EVENTS:
#║ • Script > 'SceneManager.call(Scene_SVNMenu)'
#║
#║ HOW TO ADD EVENTS:
#║ • To add an event under the 'Talk' category, add the comment 'npc' onto
#║   the event. To add an event under the 'Investigate' category, add the
#║   comment 'object' onto the event.
#║
#║ • If you want an event to disappear from the list, simply create a new page
#║   on that event WITHOUT a comment.
#║
#║ *You may want to execute the Wait command on your event first before calling
#║  the menu again to give the system time to refresh if you just triggered a
#║  switch to change the event's active page. We're working on fixing that.
#╚═=═=════════════════════════════════════════════════════════════════════════=#

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ System Functions - Do NOT edit unless you know what you're doing.
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Game_Event
  def event
    return @event
  end
end

class Game_Event < Game_Character
 
  def note
    return "" if !@page || !@page.list || @page.list.size <= 0
    comment_list = []
    @page.list.each do |item|
      next unless item && (item.code == 108 || item.code == 408)
      comment_list.push(item.parameters[0])
    end
    comment_list.join("\r\n")
  end  
end

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ Main Window - Lists all of the available primary commands.
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Window_VNMenu < Window_HorzCommand
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 def initialize
   super(0, 0)
 end
 #--------------------------------------------------------------------------
 # * Get Window Width
 #--------------------------------------------------------------------------
 def window_width
   return Graphics.width
 end
 
 #--------------------------------------------------------------------------
 # * Get Window Height
 #--------------------------------------------------------------------------
 def window_height
   return 50
 end
 #--------------------------------------------------------------------------
 # * Update Window Position
 #--------------------------------------------------------------------------
 def update_placement
   self.x = (Graphics.width - width) / 2
   self.y = (Graphics.height * 1.6 - height) / 2
 end
 #--------------------------------------------------------------------------
 # * Create Command List
 #--------------------------------------------------------------------------
 def make_command_list
   add_command("Talk", :do_talk)
   add_command("Inspect", :do_inspect)
   add_command("Load", :do_load)
   add_command("Save", :do_save)
 end
end

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ Talk Window - Lists all NPC Names found on the current map. 
#║             - Don't forget to add the comment 'vn_npc' to your event!
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Window_VNTalk < Window_Command
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
  def initialize(x,y)
    super(x,y)
    @data = []
    activate
    refresh
  end
 #--------------------------------------------------------------------------
 # * Get Window Height
 #--------------------------------------------------------------------------
 def window_height
   return Graphics.height - 50
 end
 #--------------------------------------------------------------------------
 # * Create NPC List
 #--------------------------------------------------------------------------  
 def make_command_list
   $game_map.events.each do |key,event|
     if event.note == 'vn_npc'
       add_command(event.event.name,:npctalk,true,event)
     end
   end
 end

  def refresh
    create_contents
    draw_all_items
  end
end

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ Inspect Window - Lists all Object Names found on the current map. 
#║                - Don't forget to add the comment 'vn_object' to your event!
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Window_VNInspect < Window_Command
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
  def initialize(x,y)
    super(x,y)
    @data = []
    activate
    refresh
  end
 #--------------------------------------------------------------------------
 # * Get Window Height
 #--------------------------------------------------------------------------
 def window_height
   return Graphics.height - 50
 end
 #--------------------------------------------------------------------------
 # * Create Object List
 #--------------------------------------------------------------------------  
 def make_command_list
   $game_map.events.each do |key,event|
     if event.note == 'vn_object'
       add_command(event.event.name,:objinspect,true,event)
     end
   end
 end

  def refresh
    create_contents
    draw_all_items
  end
end

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ Scene_VNMenu - Performs basic processing related to the VN Menu.
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Scene_VNMenu < Scene_MenuBase

  def start
   super
   create_vnmenu_window
   create_vntalk_window
   create_vninspect_window
 end
 
 #--------------------------------------------------------------------------
 # * Create Main Window
 #--------------------------------------------------------------------------
  def create_vnmenu_window
   @command_window = Window_VNMenu.new
   @command_window.set_handler(:do_talk,   method(:do_talk))
   @command_window.set_handler(:do_inspect,   method(:do_inspect))
   @command_window.set_handler(:do_load,   method(:do_load))
   @command_window.set_handler(:do_save,   method(:do_save))
   @command_window.set_handler(:cancel, method(:do_cancel))
 end
 
 #--------------------------------------------------------------------------
 # * Create Talk Window
 #--------------------------------------------------------------------------
 def create_vntalk_window
  @talk_window = Window_VNTalk.new(0,50)
  @talk_window.viewport = @viewport
  @talk_window.hide
  @talk_window.deactivate
  @talk_window.set_handler(:cancel, method(:cancel_talk))
  @talk_window.set_handler(:npctalk,method(:npctalk))
end

 def npctalk
   return_scene 
   @talk_window.current_data[:ext].start
   
 end
 
  def cancel_talk
  @talk_window.hide
  @talk_window.unselect
  @talk_window.deactivate
  @command_window.activate
end
 
 def do_talk
   @talk_window.refresh
   @talk_window.show
   @talk_window.select(0)
   @talk_window.activate
   end

 #--------------------------------------------------------------------------
 # * Create Inspect Window
 #--------------------------------------------------------------------------
 def create_vninspect_window
  @inspect_window = Window_VNInspect.new(0,50)
  @inspect_window.viewport = @viewport
  @inspect_window.hide
  @inspect_window.deactivate
  @inspect_window.set_handler(:cancel, method(:cancel_inspect))
  @inspect_window.set_handler(:objinspect,method(:objinspect))
end

 def objinspect
   return_scene 
   @inspect_window.current_data[:ext].start
   
 end
 
  def cancel_inspect
  @inspect_window.hide
  @inspect_window.unselect
  @inspect_window.deactivate
  @command_window.activate
end
 
 def do_inspect
   @inspect_window.refresh
   @inspect_window.show
   @inspect_window.select(0)
   @inspect_window.activate
   end
 end
 
 #--------------------------------------------------------------------------
 # * Call Load Menu
 #--------------------------------------------------------------------------
  def do_load
   SceneManager.call(Scene_Load)
 end
 
 #--------------------------------------------------------------------------
 # * Create Save Menu
 #--------------------------------------------------------------------------
  def do_save
   SceneManager.call(Scene_Save)
 end
 
 #--------------------------------------------------------------------------
 # * Close VN Menu
 #--------------------------------------------------------------------------
  def do_cancel
    return_scene
  end