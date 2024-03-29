module analysis::grammars::dramb::Popups

import salix::util::WithPopups;
import analysis::grammars::dramb::Model;

str popupStyle() 
    =   ".tooltip {
        'background: lightgrey;
        'color: black;
        'font-weight: normal;
        'padding: 4px 8px;
        'font-size: 16px;
        'border-radius: 4px;
        'opacity: 1;
        'max-width: 350px;
        '}
        '.large-tooltip .tooltip-inner {
        'max-width: 20px;
        '}
        '@media screen and (max-width: 300px) {
        '.large-tooltip .tooltip-inner {
        '  max-width: 100%;
        '}
        '}
        '.arrow,
        '.arrow::before {
        '  position: absolute;
        '  width: 8px;
        '  height: 8px;
        '  background: inherit;
        '}
        '.arrow {
        '  visibility: hidden;
        '}
        '.arrow::before {
        '  visibility: visible;
        '  content: \'\';
        '  transform: rotate(45deg);
        '}
        '.container-fluid {
        'padding: 150px 150px 150px 150px
        '}
        'body {
        'display: inline-block;
        'width: 100%
        '}
        '}";

Popups popups(Model m) 
    = [
        *[*sentencePopups() | m.tab is sentence],
        *[<"#grammar", popup("The current grammar is edited here. Which one is used depends on the commit and revert buttons.", placement=top())> | m.tab is grammar], 
        *[<"#diagnose", popup("A detailed story line of the diagnosis of the current sentence is told here. Read top to bottom!", placement=top())> | m.tab is diagnosis],     
        *[<"#graphic", popup("We get a general feel for the differences between the alternatives in the graphical view.", placement=top())> | m.tab is graphic],  
        *[<"#file-menu", popup("Use the file menu to save all your work and come back to it later, or use it in continuous testing processes.", placement=top())> | m.tab is sentence]     
    ];

Popups sentencePopups()
    = [
        <"#sentence-editor", popup("The current input sentence under investigation is edited here. It is the main input to the diagnosis process next to the grammar.", placement=bottom())>,
        <"#first-impressions", popup("We get a rough impression of the severity of the problem here, if any.", placement=top())>,
        <"#stash-button", popup("These tool buttons help by automatically trying out random simplifications, randomly generating ambiguous sentences, stashing examples for future reference, and focusing on deeper nested ambiguities", placement=left())>,
        <"#nonterminalChoice", popup("Pick the non-terminal to apply to the current sentence here.", placement=left())>
    ];