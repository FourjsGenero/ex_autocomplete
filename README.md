# ex_autocomplete
Examples showing the new autocomplete functionality that was added in Genero 3.0

Type a country into the first field and note the auto complete options that appear.  Select an option to save typing

Note what happens if you type slowly versus type quickly.  The ON CHANGE won't be called unless a certain number of milliseconds occur

Key things to note are
1 - the COMPELTER attribute in the .per
2 - The use of ON CHANGE
3 - The use of DIALOG.setcompelteritems to populate the list
Not shown but it is upto the developer to ensure that the code in ON CHANGE does not take a long time to run

