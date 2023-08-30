module analysis::grammars::dramb::Popups

import salix::util::WithPopups;

Popups popups() 
    = [
        <"#input", popup("The current input sentence under investigation is edited here. The text area is free form. The buttons influence its contents.")>,
        <"#grammar", popup("The current grammar is edited here. Which one is used depends on the commit and revert buttons.")>, 
        <"#diagnosis", popup("A detailed story line of the diagnosis of the current sentence is told here. Read top to bottom!")>,     
        <"#graphic", popup("We get a general feel for the differences between the alternatives in the graphical view.")>,     
        <"#file-menu", popup("Use the file menu to save and restore all information currently present.")>     
    ];