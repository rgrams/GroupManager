tool
extends WindowDialog
################################### R E A D M E ##################################
# 
#
#

##################################################################################
#########                     Imported classes/scenes                    #########
##################################################################################
#var GroupManagerWinScn = preload("../GroupManagerWindow.tscn");

##################################################################################
#########                       Signals definitions                      #########
##################################################################################
signal onSave(groupID, groupDesc, groupMethods);

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################

export (NodePath) var path2GroupManagerRoot = NodePath("..");

var methodList
var memberList

var groupManagerLogicRoot;
var currentGroupID;


##################################################################################
#########                          Init code                             #########
##################################################################################
func _notification(what):
	if (what == NOTIFICATION_INSTANCED):
		methodList = get_node("Margin/Split 1/Split Top/Methods Box/methodList")
		memberList = get_node("Margin/Split 1/Scenes Box/memberList")
	elif(what == NOTIFICATION_READY):
		groupManagerLogicRoot = get_node(path2GroupManagerRoot);


##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
func showGroup(inGroup, group2SceneValidationInfo):
	
	#
	currentGroupID = inGroup;
	memberList.clear();
	set_title("Group: " + currentGroupID)
	methodList.clear();
	get_node("Margin/Split 1/Split Top/Descr Box/description").set_text("");
	
	#
	if(groupManagerLogicRoot.hasDescription4Group(currentGroupID)):
		var desc = groupManagerLogicRoot.getGroupDesc(inGroup);
		get_node("Margin/Split 1/Split Top/Descr Box/description").set_text(desc);
		var methods = groupManagerLogicRoot.getGroupMethodsInList(inGroup);
		for method in methods: methodList.add_item(method);
	
	#
	var linkedScenes = group2SceneValidationInfo[inGroup];
	for scene in linkedScenes:
#		get_node("Margin/Split 1/Scenes Box/members").add_item(scene.filePath);
		addScene2SceneList(currentGroupID, scene)
	
	popup();

func addScene2SceneList(inGroup, inScene):
	print("-------Adding scene to scene list-------");
	print("scene name: ", inScene.filePath, " group: ", inGroup);
	
	var validationStatus = groupManagerLogicRoot.getValidationStatus4Scene(inGroup, inScene.filePath)
	memberList.add_item(inScene.filePath);
	var lastItemIdx = memberList.get_item_count() - 1;
	if(validationStatus == groupManagerLogicRoot.VALIDATION_STAT_4_SCENE_OK ):
		memberList.set_item_icon(lastItemIdx, groupManagerLogicRoot.ICO_OK);
		memberList.set_item_tooltip(lastItemIdx, "All methods implemented")
	else:
		memberList.set_item_icon(lastItemIdx, groupManagerLogicRoot.ICO_ERROR);
		memberList.set_item_tooltip(lastItemIdx, "Need to implement one or more methods")


#	groupManagerLogicRoot

##################################################################################
#########              Should be implemented in inheritanced             #########
##################################################################################

##################################################################################
#########                    Implemented from ancestor                   #########
##################################################################################

##################################################################################
#########                       Connected Signals                        #########
##################################################################################
func _on_addMethodBtn_pressed():
	get_node("AddMethodPopup").popup();

func _on_removeMethod_pressed():
	var selectedItems = methodList.get_selected_items();
	for idx in selectedItems:
		methodList.remove_item(idx);

func _on_AddMethodPopup_onMethodSave(inMethodName, inParamString):
	methodList.add_item(inMethodName + "(" + inParamString + ")");

func _on_OK_Button_pressed():
	var methods = putMethodsInfo2String();
	var desc = get_node("Margin/Split 1/Split Top/Descr Box/description").get_text();
	emit_signal("onSave", currentGroupID, desc, methods)
	hide();

func _on_Cancel_Button_pressed():
	hide()

func putMethodsInfo2String():
	var methodsString = "";
	var nmbOfMethods = methodList.get_item_count();
	for idx in range(nmbOfMethods):
		methodsString = methodsString + "|" + methodList.get_item_text(idx);
	methodsString = methodsString.strip_edges()
	if(methodsString.begins_with("|")):
		methodsString = methodsString.right(1);
	return methodsString;

##################################################################################
#########     Methods fired because of events (usually via Groups interface)  ####
##################################################################################

##################################################################################
#########                         Public Methods                         #########
##################################################################################

##################################################################################
#########                         Inner Methods                          #########
##################################################################################

##################################################################################
#########                         Inner Classes                          #########
##################################################################################


##################################################################################
#########                        Window Resizing                         #########
##################################################################################
var min_size = Vector2(325, 250)

func _on_Resize_Button_button_down():
	set_process_input(true)

func _on_Resize_Button_button_up():
	set_process_input(false)

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		var size = get_size() + event.relative_pos
		size.x = max(min_size.x, size.x)
		size.y = max(min_size.y, size.y)
		set_size(size)
