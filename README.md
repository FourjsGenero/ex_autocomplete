# ex_autocomplete
Examples showing the new autocomplete functionality that was added in Genero 3.0

Type a country into the first field and note the auto complete options that appear.  

Type a place name or airport code into the second edit widget.

Note what happens if you type slowly versus type quickly.  The ON CHANGE won't be called unless a certain number of milliseconds elapse

Key things to note include ...
* the COMPELTER attribute in the .per
* the use of ON CHANGE
* the use of DIALOG.setcompleteritems to populate the list

The autoset checkbox is tied to some code that automatically sets the value if there is only one value returned in the list.

Note the first example searches for matches that begin with the entered string, whilst the second example searches for matches that contain the expected string.  You have control over the matching expression.

Not shown but it is upto the developer to ensure that the code in ON CHANGE does not take a long time to run.  

