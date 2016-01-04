#!/usr/bin/tclsh

###############################################################################
##
## File: SaladGenerator.tcl
## Project: SaladGenerator
## Author: James Kuczynski
## Email: jkuczyns@cs.uml.edu
## Project Description: This GUI project allows the user to select how
##                      many items of each salad catagory he wants. The
##                      program will then read items from a series of
##                      resource files filled with ingredients.  It will
##                      then randomly select ingredients, and display
##                      the resulting salad recipy.
##
## File Description: 
##
## To run, execute "tclsh [file_name.tcl]"
## spinbox: http://wiki.tcl.tk/1457
##
## TODO: after adding a item, remove the item from the original list.
##       add base case for if there are no more elements in list.
##       Make control flow more clear.
##       Create better icon images.
##
## Created: 
## Last Modified: 
##
###############################################################################

package require Tcl
package require Tk


# Read data from files
proc listFromFile {filename} {

    set f [open $filename r]
    set data [split [string trim [read $f]]]
    close $f
    return $data
}


# Accessor procedures
proc getGreenCount {} {

    puts $::greenCount
    return $::greenCount
}

proc getVeggieCount {} {

    puts $::veggieCount
    return $::veggieCount
}

proc getCheeseCount {} {

    puts $::cheeseCount
    return $::cheeseCount
}

proc getMeatCount {} {

    puts $::meatCount
    return $::meatCount
}


# Set up the main window
proc initUi {} {
    wm title . "Recipe Generator"
    image create photo appIcon -format png -file res/icon/salad.png
    wm iconphoto . -default appIcon
}



# Create and set up the widgets
proc createWidgets {} {

    label .titleTextLabel -text "Recipe Generator" -textvariable labelText
    image create photo myImgObj -file "res/icon/salad.png" -width 240 -height 111
    label .myImgLabel -image myImgObj

    image create photo greenImage -file "res/icon/greens.png" -width 90 -height 31
    image create photo green2Image -file "res/icon/greens_2.png" -width 90 -height 31
    label .greenLabel -image greenImage

    image create photo veggieImage -file "res/icon/vegetables.png" -width 90 -height 31
    image create photo veggie2Image -file "res/icon/vegetables_2.png" -width 90 -height 31
    label .veggieLabel -image veggieImage

    image create photo cheeseImage -file "res/icon/cheese.png" -width 90 -height 31
    image create photo cheese2Image -file "res/icon/cheese2.png" -width 90 -height 31
    label .cheeseLabel -image cheeseImage

    image create photo meatImage -file "res/icon/meat.png" -width 90 -height 31
    image create photo meat2Image -file "res/icon/meat_2.png" -width 90 -height 31
    label .meatLabel -image meatImage

    image create photo shelfImage -file "res/icon/closed_curtains.png" -width 320 -height 240
    image create photo shelf2Image -file "res/icon/shelf.png" -width 320 -height 240
    label .shelfLabel -image shelfImage

    spinbox .greenSpinbox -textvariable ::greenCount -from 0 -to 3 -increment 1 -width 2 -command getGreenCount
    spinbox .veggieSpinbox -textvariable ::veggieCount -from 0 -to 3 -increment 1 -width 2 -command getVeggieCount
    spinbox .cheeseSpinbox -textvariable ::cheeseCount -from 0 -to 3 -increment 1 -width 2 -command getCheeseCount
    spinbox .meatSpinbox -textvariable ::meatCount -from 0 -to 3 -increment 1 -width 2 -command getMeatCount

    button .myButton -text "Generate!" -font {Helvetica -14 bold} -height 5 -width 10 -command loadResults
}


# Set up the layout
proc createLayout {} {

    grid .titleTextLabel -column 0 -row 0 -columnspan 4
    grid .myImgLabel    -column 0 -row 1 -columnspan 4
    grid .greenLabel    -column 0 -row 3
    grid .veggieLabel   -column 1 -row 3
    grid .cheeseLabel    -column 2 -row 3
    grid .meatLabel     -column 3 -row 3
    grid .greenSpinbox  -column 0 -row 4
    grid .veggieSpinbox -column 1 -row 4
    grid .cheeseSpinbox  -column 2 -row 4
    grid .meatSpinbox   -column 3 -row 4
    grid .myButton      -column 0 -row 5 -columnspan 4
    grid .shelfLabel    -column 0 -row 6 -columnspan 4
}


## Bind widgets to signals and actions
proc bindWidgets {} {

    bind .greenLabel <Enter> {%W configure -image green2Image}
    bind .greenLabel <Leave> {%W configure -image greenImage}
    bind .veggieLabel <Enter> {%W configure -image veggie2Image}
    bind .veggieLabel <Leave> {%W configure -image veggieImage}
    bind .cheeseLabel <Enter> {%W configure -image cheese2Image}
    bind .cheeseLabel <Leave> {%W configure -image cheeseImage}
    bind .meatLabel <Enter> {%W configure -image meat2Image}
    bind .meatLabel <Leave> {%W configure -image meatImage}
}


#select ingredients
proc requestIngredients {cataLstCount cataLst} {
    
    set chosenCataLst ""
    puts "cataLstCount=$cataLstCount"
    for {set i 0} {$i < $cataLstCount} {incr i} {
        
        set listSize [llength $cataLst]
        set randNum [expr { int(floor(rand() * $listSize)) }]
        puts "Generated randum number: $randNum"

        set count 0
    
        while {$count < $listSize} {
    
            if {$randNum == $count} {
        
                #put item in var; delete index; dec listSize; returns
                puts "(pre) current list: $cataLst"
                set item [lindex $cataLst $count]
                set cataLst [lreplace $cataLst $count $count]
                lreplace $cataLst 0 [llength $cataLst]
                puts "(post) current list: $cataLst"
                lappend chosenCataLst $item
                break
            } else {
        
                incr count
            }
        }
        
    }
    
    return $chosenCataLst
}


#pair chosen items with their images & labels
proc pairItemWithIcon {chosenItemLst} {
    
    lappend greenImgObjLst [image create photo chIObj -format png -file "res/icon/[lindex $chosenItemLst $i].png" -width 240 -height 111]
    lappend greenLabelLst [label .[lindex $chosenItemLst $i] -image [lindex $greenImgObjLst $i] ]
    
    return $greenLabelLst
}


#load and display chosen items
proc load1Res {chosenItemLst rowNum} {
    
    set y 300
    for {set i 0} {$i < $rowNum} {incr i} {
        set y [expr $y + 50]
    }
    
    for {set i 0} {$i < [llength $chosenItemLst]} {incr i} {

        lappend itemImgObjLst [image create photo [lindex $chosenItemLst $i]ImgObj -format png -file "res/icon/[lindex $chosenItemLst $i].png" -width 50 -height 44]
        lappend itemLabelLst  [label .[lindex $chosenItemLst $i] -image [lindex $itemImgObjLst $i] ]
        place [lindex $itemLabelLst $i] -x [expr {($i+1)*75}] -y $y
        #puts "loading: [lindex $itemImgObjLst $i], [lindex $itemLabelLst $i]"
    }
}


#"master" procedure for calling final display sequence
#This is triggered when the user presses the button
proc loadResults {} {

    set chosenGreenLst  [requestIngredients [getGreenCount]  $::greenLst]
    set chosenVeggieLst [requestIngredients [getVeggieCount] $::veggieLst]
    set chosenCheeseLst [requestIngredients [getCheeseCount] $::cheeseLst]
    set chosenMeatLst   [requestIngredients [getMeatCount]   $::meatLst]
    
    puts "Chosen greens:  $chosenGreenLst"
    puts "Chosen veggies: $chosenVeggieLst"
    puts "Chosen cheeses: $chosenCheeseLst"
    puts "Chosen meats:   $chosenMeatLst"

    load1Res $chosenGreenLst  0
    load1Res $chosenVeggieLst 1
    load1Res $chosenCheeseLst 2
    load1Res $chosenMeatLst   3

    .shelfLabel configure -image shelf2Image
}


#main procedure
proc main {} {

    #TODO: these are global scope--possibly implement this differently
    set ::veggieLst [listFromFile res/ingredients/Veggies.txt] 
    set ::greenLst  [listFromFile res/ingredients/Greens.txt]
    set ::cheeseLst [listFromFile res/ingredients/Cheeses.txt]
    set ::meatLst   [listFromFile res/ingredients/Meats.txt]
    
    initUi
    createWidgets
    createLayout
    bindWidgets
    
    
}
main


