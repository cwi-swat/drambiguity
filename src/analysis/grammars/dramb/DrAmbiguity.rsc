module analysis::grammars::dramb::DrAmbiguity

import DateTime;
import salix::Core;
import salix::HTML;
import salix::Node;
import salix::Index;
import salix::App;
import salix::util::WithPopups;
import salix::lib::Bootstrap;
import lang::rascal::format::Grammar;
import ParseTree;
import IO;
import List;
import Set;
import String;
import Boolean;  
import util::Math;
import analysis::grammars::dramb::Simplify;
import analysis::grammars::dramb::GenerateTrees;
import analysis::grammars::dramb::Popups;
import analysis::grammars::dramb::Detection;
import util::Reflective;
import analysis::grammars::dramb::Util;
import Grammar;
import analysis::grammars::dramb::Diagnose; 
import analysis::grammars::dramb::Brackets;
import analysis::grammars::dramb::GrammarEditor;
import util::Maybe;
import ValueIO;
import vis::Text;

private loc root = |project://drambiguity/src|;

@synopsis{start DrAmbiguity with a fresh grammar and an example input sentence}
App[Model] drAmbiguity(type[&T <: Tree] grammar, loc input) 
  = drAmbiguity(model(grammar, input=readFile(input)));
  
@synopsis{Continue DrAmbiguity with a previously saved project}  
App[Model] drAmbiguity(loc project) 
  = drAmbiguity(readBinaryValueFile(#Model, project));

@synopsis{start DrAmbiguity with a fresh grammar and an example input sentence}
App[Model] drAmbiguity(type[&T <: Tree] grammar, str input) 
  = drAmbiguity(model(grammar, input=input));

@synopsis{start DrAmbiguity with a fresh grammar and no input sentence yet}
App[Model] drAmbiguity(type[&T <: Tree] grammar) 
  = drAmbiguity(model(grammar));
  
@synopsis{start DrAmbiguity with a fresh grammar and a corresponding example (ambiguous) example tree}  
App[Model] drAmbiguity(type[&T <: Tree] grammar, &T input) 
  = drAmbiguity(model(completeLocs(input), grammar));

@synopsis{This is the internal work horse that boots up the Salix application that is called DrAmbiguity.}  
App[Model] drAmbiguity(Model m, str id="DrAmbiguity") 
  = webApp(
      makeApp(
        id, 
        Model () { return m; }, 
        withIndex(
          "Dr Ambiguity", 
          id, 
          view, 
          css=["https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"], 
          scripts=[
            "https://code.jquery.com/jquery-3.2.1.slim.min.js",
            "https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/js/bootstrap.bundle.min.js"
          ]
        ),
        update
      ),
      root
    );

App[Model] docDrAmbiguity(Model m) 
  = withPopupsWeb(popups(), m, view, "Dr Ambiguity",
          extraCss="",
          css=["https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"], 
          scripts=[
            "https://code.jquery.com/jquery-3.2.1.slim.min.js",
            "https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/js/bootstrap.bundle.min.js"
          ]);

data Tab 
  = sentence()
  | graphic()
  | grammar()
  | diagnosis()
  ;

Model model(&T<:Tree input, type[Tree] grammar, Tab tab=sentence()) 
  = model(grammar, tab=tab)[tree=just(input)];

Model model(loc saved) = readBinaryValueFile(#Model, saved);

data Model 
  = model(type[Tree] grammar,
      str input = "",
      Maybe[Tree] tree = saveParse(grammar, input),
      Maybe[loc] file = just(|home:///myproject.dra|),
      str grammarText = format(grammar),
      str commitMessage = "",
      lrel[datetime stamp, str msg, str grammar] grammarHistory = [<now(), "initial", grammarText>],
      lrel[str input, Symbol nt, Maybe[Tree] tree, str status]  examples = [],
      int generationEffort = 5, 
      list[str] errors = [],
      bool labels = false, 
      bool literals = false,
      bool \layout = false,
      bool chars = true,
      Tab tab = sentence()
    );

data Msg 
   = labels()
   | literals()
   | \layout()
   | chars()
   | focus()
   | simplify()
   | freshSentence()
   | newInput(str x)
   | selectExample(int count)
   | removeExample(int count)
   | changeGenerationEffort(int count)
   | storeInput()
   | newGrammar(str x)
   | commitGrammar(int selector)
   | setStartNonterminal(Symbol s)
   | clearErrors()
   | removeGrammar(int count)
   | saveProject(loc file)
   | loadProject(loc file)
   | filename(loc file)
   | nofilename()
   | commitMessage(str msg)
   | setTab(Tab t)
   ;

Model update(setTab(Tab t), Model m) = m[tab=t];
Model update(clearErrors(), Model m) = m[errors=[]];
Model update(labels(), Model m) = m[labels = !m.labels];
Model update(literals(), Model m) = m[literals = !m.literals];
Model update(\layout(), Model m) = m[\layout = !m.\layout];
Model update(Msg::chars(), Model m) = m[chars = !m.chars];
Model update(Msg::focus(), Model m) = focus(m);
Model update(Msg::filename(loc f), Model m) = m[file=just(f)];
Model update(nofilename(), Model m) = m[file=nothing()];
Model update(commitMessage(str msg), Model m) = m[commitMessage=msg];
Model update(removeGrammar(int count), Model m) = m[grammarHistory = m.grammarHistory[0..count-1] + m.grammarHistory[count..]];

Model update(loadProject(loc f), Model m) {
  try {
    m = readBinaryValueFile(#Model, f);
    m.errors = [];
    return m;
  } 
  catch value x: {
    m.errors += ["IO exception: <x>"];
    return m;
  }
}

Model update(saveProject(loc f), Model m) {
  writeBinaryValueFile(f, m);
  return m;
}
 
Model update(selectExample(int count), Model m) {
  m.tree = m.examples[count-1].tree;
  // println("new tree: <m.tree>");
  m.grammar = type[Tree] ng := type(m.examples[count-1].nt, m.grammar.definitions) ? ng : m.grammar;
  m.input = m.examples[count-1].input;
  if (m.tree == nothing()) {
    m.errors += ["input sentence has parse error"];
  }
  int i ="fiets";
  return m;
}

Model update(removeExample(int count), Model m) = m[examples = m.examples[0..count-1] + m.examples[count..]];
Model update(changeGenerationEffort(int count), Model m) = m[generationEffort = count > 0 && count < 101 ? count : m.generationEffort];
Model update(newGrammar(str x), Model m) {
  m.grammarText=x;
  return m;
}

str status(nothing()) = "error";
str status(just(Tree x)) = "no amb." when /amb(_) !:= x;
default str status(just(Tree x)) = "amb";

Model update(storeInput(), Model m) = m[examples= [<m.input, analysis::grammars::dramb::Util::symbol(m.tree.val), m.tree, status(m.tree)>] + m.examples];

Model update(setStartNonterminal(Symbol s), Model m) {
  if (type[Tree] new := type(s, m.grammar.definitions)) {
    m.grammar = new;
    
    try {
      m.tree = just(reparse(m.grammar, m.input));
      m.errors = [];
    }
    catch ParseError (l) : {
      m.errors += ["parse error in input at <l>"];
      m.tree = nothing();
    }
    catch value v: {
      m.errors += ["unexpected error: <v>"];
      m.tree = nothing();
    }
  }
  
  return m;
}

Model update(Msg::commitGrammar(int selector), Model m) {
  println("committing grammar <selector>");
  try {
    str newGrammar = "";
    
    if (selector == -1) {
      m.grammarHistory = [<now(), m.commitMessage, m.grammarText>] + m.grammarHistory;
      newGrammar = m.grammarText;
    }
    else {
      newGrammar = m.grammarHistory[selector-1].grammar;
      m.grammarText = m.grammarHistory[selector-1].grammar;
    }
    
    m.commitMessage = "";
    m.errors = [];
    m.grammar = commitGrammar(m.grammar.symbol, newGrammar);
        
    // then reparse the input
    try {
      m.tree = just(reparse(m.grammar, m.input));
    }
    catch ParseError (l) : {
      m.tree = nothing();
      m.errors += ["parse error in input at <l>"];
    }
    catch value v: {
      m.errors += ["unexpected error: <v>"];
      m.tree = nothing();
    }
    
    // and reparse the examples
    m.examples = for (<str ex, Symbol s, Maybe[Tree] _t, str _st> <- m.examples) {
      try {
        tt = reparse(m.grammar, s, ex);
        append <ex, s, just(tt), status(just(tt))>;
      }
      catch ParseError(_e) :
        append <ex, s, nothing(), status(nothing())>;
      catch value v: {
        append <ex, s, nothing(), status(nothing())>;
        m.errors += ["unexpected error: <v>"];
      }  
    }
  }
  catch value x: 
    m.errors += ["grammar could not be processed due to <x>"];
  
  return m;
}

Model update(newInput(str new), Model m) {
  try {
    m.input = new;
    m.tree = saveParse(m.grammar, new);
    m.errors = [];
  }
  catch ParseError(l) : {
    m.errors += ["parse error in input at <l>"];
    m.tree = nothing();
  }
  
  return m;
}

Model update(Msg::simplify(), Model m) {
  saved = m.input;

  gr = type(symbol(m.tree.val), m.grammar.definitions);
  m.tree=just(completeLocs(reparse(gr, simplify(gr, m.tree.val, effort=m.generationEffort * 100))));
  m.input = "<m.tree.val>";

  if (m.input == saved) {
    m.errors += ["no simpler example found"]; 
  }
  
  return m;
}

Model update(Msg::freshSentence(), Model m) = freshSentences(m);

Model freshSentences(Model m) {
  if (options:{_,*_} := randomAmbiguousSubTrees(m.grammar, m.generationEffort)) {
    new = m.examples == [] ? [*options] : [op | op <- options, !any(e <- m.examples, just(op) := e.tree)];
    if (new != []) {
      m.examples += [<"<n>", analysis::grammars::dramb::Util::symbol(n), just(completeLocs(n)), status(just(n))> | n <- new];
      m.errors = [];
    }
    else {
      m.errors += ["no new ambiguous sentences found; only <size(options)> existing examples."];
    }
    
    return m;
  }
  else {
    Tree n = randomTree(completeGrammar(m.grammar));

    if (m.input == "") {
      m.input = "<n>";
      m.tree = just(n);
    }
    
    m.errors += ["no ambiguous sentences found"];

    return m;
  }
}

void graphic(Model m) {
  // for lack of a visual, here we use ascii art:
   if (m.tree is just) {
      nestingDepth = ambNestingDepth(m.tree.val);
      println("nestingDepth is <nestingDepth>");
      if (nestingDepth > 3) {
        alertWarning("This ambiguous forest has deeply nested ambiguity (<nestingDepth>). Since visualizations grow exponentially in the nesting depth, it is better to focus on the deepest cluster first.");
        focusButton();
        return;
      }

      table(class("table"), class("table-hover"), class("table-sm"), () {
        if (amb(alts) := m.tree.val) {  
            thead(() {
              for (_ <- alts) {
                th(attr("scope", "col"), () {
                  text("Alternative");
                });
              }
            });
            tbody(() {
              tr(() {
                for (Tree t <- alts) {
                  td(() {
                    pre(() {
                      text(prettyTree(t, characters = m.chars, literals=m.literals, \layout=m.\layout));
                    });
                  });
                }
              });       
            }); 
        }
        else {
          thead(() {
            th(attr("scope", "col"), () {
              text("Tree");
            });
          });
          tbody(() {
            pre(() {
              text(prettyTree(m.tree.val, characters = m.chars, literals=m.literals, \layout=m.\layout));
            });
          });
        }
      });
   }
}
 
Msg onNewSentenceInput(str t) = newInput(t);
Msg onNewGrammarInput(str t) = newGrammar(t); 
Msg onTab(Tab t) = setTab(t);
 
void view(Model m) {
   container(true, () {
    div(() {
      ul(class("nav nav-pills"), id("tabs"), () {
          li(class("nav-item dropdown"), () {
            a(class("nav-link dropdown-toggle"), \data-toggle("dropdown"), id("file-menu"), role("button"), hasPopup(true), expanded(false), "File");
            fileUI(m);
          });

          li(class("nav-item"),() {
            a(class("nav-link <if (m.tab is grammar) {>active<}>"), href("#grammar"), onClick(onTab(Tab::grammar())), "Grammar"); 
          });

          li(class("nav-item"), () {
            a(class("nav-link <if (m.tab is sentence) {>active<}>"), href("#input"), onClick(onTab(Tab::sentence())), "Sentence");
          });

          li(class("nav-item"), () {
            a(class("nav-link <if (m.tab is graphic) {>active<}>"), href("#graphic"), onClick(onTab(Tab::graphic())), "Graphic");
          });

          li(class("nav-item"), () {
            a(class("nav-link <if (m.tab is diagnosis) {>active<}>"), href("#diagnose"), onClick(onTab(Tab::diagnosis())), "Diagnosis"); 
          });
      });
    });
        
    div(class("tab-content"), id("tabs"),  () {
      div(class("tab-pane <if (m.tab is sentence) {>active<}>"), id("input"), () {
        if (m.tab is sentence) {
          inputPane(m);
        }
      });
     
      div(class("tab-pane <if (m.tab is graphic) {>active<}>"), id("graphic"), () {
        if (m.tab is graphic) {
          graphicPane(m);
        }
      });
      
      div(class("tab-pane <if (m.tab is grammar) {>active<}>"), id("grammar"), () {
        if (m.tab is grammar) {
          grammarPane(m);
        }
      });
      
      div(class("tab-pane <if (m.tab is diagnosis) {>active<}>"), id("diagnose"), () {
          if (m.tree is just) {
              diagnose(m.tree.val);
          }
          else {
             alertInfo("Diagnosis of ambiguity is unavailable while the input sentence has a parse error.");
          } 
      });
    });
    
    if (m.errors != []) {
      row(() {
        column(10, md(), () {
           for (e <- m.errors) {
            alertDanger(e);
           }
        });
        column(2, md(), () {
          div(class("list-group list-group-flush"), style(<"list-style-type","none">), () {
            button(class("btn-secondary"), onClick(clearErrors()), "Clear");
          });
        });
      });
    }
  });
}

Msg onCommitMessageInput(str m) {
  return commitMessage(m);
}

void grammarPane(Model m) {
  row(() {
    column(10, md(), () {
        textarea(class("form-control"), style(<"width","100%">), rows(25), onChange(onNewGrammarInput), \value(m.grammarText));
    });
    column(2, md(), () {
      div(class("list-group"), () { 
        input(class("list-group-item"), style(<"width","100%">), \type("text"), onChange(onCommitMessageInput), \value(m.commitMessage));
        if (trim(m.commitMessage) != "") {
          button(class("btn-secondary"), onClick(commitGrammar(-1)), "Commit");
        }
        else {
          button(class("btn-secondary disabled"), "Commit");
        }
      });
    });
  });
  
  if (m.grammarHistory != []) { 
          row(() {
            column(10, md(), () {
              table(class("table"), class("table-hover"), class("table-sm"), () {
                colgroup(() {
                  col(class("col-sm-1"));
                  col(class("col-sm-5"));
                  col(class("col-sm-1"));
                  col(class("col-sm-1"));
                });
                thead(() {
                  th(scope("col"), "Version");
                  th(scope("col"),"Message");
                  th(scope("col"),"Revert");
                  th(scope("col"),"Remove");
                });
                tbody(() {
                  int count = 1;
                  for (<datetime stamp, str msg, str _grammar> <- m.grammarHistory) {
                    tr( () {
                      td(printDateTime(stamp, "dd-MM-yyyy HH:mm:ss"));
                      td(msg);
                      td(() {
                           button(class("button btn-secondary"), onClick(commitGrammar(count)), "revert");
                      });
                      td(() {
                         button(class("button btn-secondary"), onClick(removeGrammar(count)), "rm");
                      });
                    });
                    count += 1;
                  }
                });
              });
            });
          });
        } 
}

Msg newAmountInput(int i) {
  return changeGenerationEffort(i);
}

Msg loadProjectInput(str file) {
 if (/C:\\fakepath\\<name:.*>/ := file) { 
   return loadProject(|home:///| + name);
 }
 else {
   return loadProject(|home:///| + file);
 }
}

Msg onProjectNameInput(str f) {
  if (trim(f) != "") {
    return filename((|home:///| + f)[extension="dra"]);
  }
  else {
    return nofilename();
  }
}

void fileUI(Model m) {
  div(class("dropdown-menu"), labeledBy("nonterminalChoice"), () {
      input(class("dropdown-item"), \type("text"), onInput(onProjectNameInput), \value(m.file != nothing() ? (m.file.val[extension=""].path[1..]) : ""));
      
      if (m.file != nothing()) {
        button(class("dropdown-item"), onClick(saveProject(m.file.val)), "Save");
      }

      button(class("dropdown-item"), attr("onclick", "document.getElementById(\'loadProjectButton\').click();"), "Load…");
      input(\type("file"), attr("accept",".dra"), style(<"display", "none">), id("loadProjectButton"), onInput(loadProjectInput));
    });
 }
 
void inputPane(Model m) {
   bool isError = m.tree == nothing();
   bool isAmb = m.tree != nothing() && amb(_) := m.tree.val ;
   bool nestedAmb = m.tree != nothing() && (amb({/amb(_), *_}) := m.tree.val || appl(_,/amb(_)) := m.tree.val);
   str  sentence = m.input;
   
   row(() {
          column(10, md(), () {
            textarea(class("form-control"), style(<"width","100%">), rows(10), onChange(onNewSentenceInput), \value(sentence), sentence); 
          });    
          column(2, md(), () {
            div(class("list-group list-group-flush"), style(<"list-style-type","none">), () {
              span(class("list-group-item"), () {
                if (isError) {
                  alertInfo("This <if (m.input == "") {>empty <}>sentence is grammatically not in <m.grammar>.");
                } 
                else {
                  alertInfo("This grammatically correct sentence is <if (!isAmb) {>not<}> ambiguous, and it has<if (!nestedAmb) {> no<}> nested ambiguity <if (nestedAmb) {>up to a depth of <ambNestingDepth(m.tree.val)> clusters<}>.");
                }
              });
              
              if (nestedAmb) {          
                focusButton();
              }

              if (m.tree is just) {          
                button(class("btn-secondary"), onClick(storeInput()), "Stash");
              }

              if (isAmb || nestedAmb) {
                simplifyButton();
              }

              button(class("btn-secondary"), onClick(freshSentence()), "Generate");

              input(class("list-group-item"), \type("range"), \value("<m.generationEffort>"), min("1"), max("100"), onChange(newAmountInput));

              button(class("btn"), class("list-group-item dropdown-toggle"), \type("button"), id("nonterminalChoice"), dropdown(), hasPopup(true), expanded(false), "Start: <format(m.grammar.symbol)>");
              div(class("dropdown-menu"), labeledBy("nonterminalChoice"), () {
                  for (Symbol x <- sorts(m.grammar)) {
                      button(class("list-group-item"), href("#"), onClick(setStartNonterminal(x)),  "<format(x)>");
                  }
              });
            });
          });
        });
        
        if (m.examples != []) { 
          ruleCount = (0 | it + 1 | /prod(_,_,_) := m.grammar.definitions);
          
          row(() {
            column(10, md(), () {
              table(class("table"), class("table-hover"), class("table-sm"), () {
                colgroup(() {
                  col(class("col-sm-1"));
                  col(class("col-sm-1"));
                  col(class("col-sm-7"));
                  col(class("col-sm-1"));
                });
                thead(() {
                  th(scope("col"), "#");
                  th(scope("col"),"Syntax category");
                  th(scope("col"),"Sentence");
                  th(scope("col"),"Status");
                  th(scope("col"),"Select");
                  th(scope("col"),"Remove");
                });
                tbody(() {
                  int count = 0;
                  for (<inp, exs, _t, st> <- m.examples) {
                    
                    tr( () {
                      count += 1;
                      td("<count>");
                      td("<format(exs)>");
                      td(() {
                        pre(() { code(inp); });
                      });
                      td(st);
                      td(() {
                           button(class("button btn-secondary"), onClick(selectExample(count)), "use");
                      });
                      td(() {
                         button(class("button btn-secondary"), onClick(removeExample(count)), "rm");
                      });
                    });
                  }
                });
              });
            });
          });
        } 
}

void focusButton() {
  button(class("btn-secondary"), onClick(focus()), "Focus on nested");
}

void simplifyButton() {
  button(class("btn-secondary"), onClick(simplify()), "Simplify");
}

void graphicPane(Model m) {
  if (m.tree is nothing) {
    alertInfo("Graphical parse tree representation unavailable due to parse error in input sentence.");
    return;
  }
  
  bool isAmb = amb(_) := m.tree.val;
  bool nestedAmb = amb({/amb(_), *_}) := m.tree.val || appl(_,/amb(_)) := m.tree.val;
   
  row(() {
          column(10, md(), () {
            graphic(m);
          });
          column(2, md(), () {
		        div(class("list-group"), style(<"list-style-type","none">), () {
		          span(class("list-group-item"), () {
                  alertInfo("This tree is <if (!isAmb) {>not<}> ambiguous, and it has<if (!nestedAmb) {> no<}> nested ambiguity.");
                });
                if (nestedAmb) {          
                  focusButton();
                }
                if (isAmb || nestedAmb) {
                  simplifyButton();
                }
      
		        div(class("list-group-item "), () { 
		          input(id("literals"), \type("checkbox"), checked(m.literals), onClick(literals()));
		          text("literals");
		        });
		        div(class("list-group-item"), () { 
		          input(\type("checkbox"), checked(m.\layout), onClick(\layout()));
		          text("layout");
		        });
		        div(class("list-group-item"), () { 
		          input(\type("checkbox"), checked(m.chars), onClick(chars()));
		          text("chars");
		        });
		    });
          });
  });
}

Model focus(Model m) {
  if (m.tree is just) {
    ambs = [a | /Tree a:amb(_) := m.tree.val, a != m.tree.val];
    
    if (ambs != []) {
      m.tree = just(ambs[arbInt(size(ambs))]);
      m.input = "<m.tree.val>";
    }
  }
  
  return m;
}
 
str prodlabel(regular(Symbol s)) = format(s);
str prodlabel(prod(label(str x,_),_,_)) = x;
str prodlabel(prod(_, list[Symbol] args:[*_,lit(_),*_],_)) = "<for (lit(x) <- args) {><x> <}>";
default str prodlabel(prod(Symbol s, _,_ )) = format(s);



