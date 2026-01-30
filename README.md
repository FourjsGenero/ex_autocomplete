# Autocomplete examples

## Description

Examples showing the autocomplete / (completer) functionality in Genero.


## Usage

Exmaple consists of four fields that demonstrate the use of the COMPLETER attribute for use with auto-completion of fields.

Field 1 - Country.  This is a simple example that demonstrates as you type letters into the field, auto completion options will appear.

Note how typing fr, a list of countries that begin fr have appeared ...

<img width="1259" height="750" alt="Image" src="https://github.com/user-attachments/assets/87cfdacb-7bf4-453e-a135-3c3a31e223b2" />

Field 2 - Country.  This is a more complex example.  It includes an option to only bring up the auto-completion list after the selected number of characters have been entered.  It also has an option in that the event of the completion list only having one item, this item will be selected.  Also changes background color of field (green if good value, red if bad value).

The screenshot shows no list as only two characters have been entered ...

<img width="1259" height="750" alt="Image" src="https://github.com/user-attachments/assets/b66ba547-4ae1-4613-b22e-b25ac266e679" />

Field 3 - Countries

Example using the tagedit widget that was added late in Genero 5 GBC that allows you to select multiple values from the drop down list

<img width="1259" height="750" alt="Image" src="https://github.com/user-attachments/assets/40bb1517-612a-4237-ba6c-71cf36765005" />

Field 4 - Example shopwing you can potentially cater for the code/desc , key/label pattern.  By putting the code/key at the beginning of the desc/label, these first few characters can be the value entered into the database.

<img width="1259" height="750" alt="Image" src="https://github.com/user-attachments/assets/b7fb1794-a81a-4824-b1a5-6dd514493452" />

Note what happens if you type slowly versus type quickly.
The ON CHANGE won't be called unless a certain number of milliseconds elapse.

Key things to note include ...
* the COMPLETER attribute in the .per
* the use of ON CHANGE in the dialog instruction
* the use of DIALOG.setCompleterItems(), to populate the list
* how the database string can be based on first few characters entered or a matches

Not shown but it is upto the developer to ensure that the code in ON CHANGE
does not take a long time to run.
