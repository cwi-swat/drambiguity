module Util

import ParseTree;
import Grammar; 
import Node;
import lang::rascal::grammar::definition::Regular;
import lang::rascal::format::Grammar;
import util::Maybe;
import util::Math;
import String;

Symbol delabel(label(str _, Symbol s)) = delabel(s);
Symbol delabel(conditional(Symbol s, set[Condition] _)) = delabel(s);
default Symbol delabel(Symbol s) = unset(s);

&T cast(type[&T] c, value x) {
  if (&T t := x) 
    return t;
  else
    throw "cast exception <c> is not a <x>";
}

Symbol symbol(appl(prod(label(str _, Symbol s), _ , _), _)) = s;
Symbol symbol(appl(regular(Symbol s), _)) = delabel(s);
Symbol symbol(amb({Tree a, *Tree _})) = symbol(a);
Symbol symbol(char(int i)) = \char-class([range(i, i)]);
default Symbol symbol(appl(prod(Symbol s, _ , _), _)) = s;

Tree reparse(type[Tree] grammar, Tree t) = reparse(grammar, symbol(t), "<t>");
Tree reparse(type[Tree] grammar, str x) = reparse(grammar, grammar.symbol, x);

Tree reparse(type[Tree] grammar, Symbol s, str x) {
  if ((s is sort || s is lex) && s notin grammar.definitions<0>) {
    throw "<s> is not in this grammar";
  }
   
  wrapped = (sort(_) !:= s) && (lex(_) !:= s);
  
  if (wrapped) {
    grammar = type(grammar.symbol, grammar.definitions + (sort("$WRAP$") : prod(sort("$WRAP$"), [s], {})));
  }
  
  if (type[Tree] subgrammar := type(wrapped ? sort("$WRAP$") : s , grammar.definitions)) {
    result = parse(subgrammar, x, allowAmbiguity=true);
    return wrapped ? completeLocs(result.args[0]) : completeLocs(result);
  }
  
  throw "this should never happen";
}

Maybe[Tree] saveParse(type[Tree] grammar, str input) {
  try {
    s= grammar.symbol;
    if ((s is sort || s is lex) && s notin grammar.definitions<0>) {
      throw "<s> is not in this grammar";
    }
   
    wrapped = (sort(_) !:= s) && (lex(_) !:= s);
  
    if (wrapped) {
      grammar = type(grammar.symbol, grammar.definitions + (sort("$WRAP$") : prod(sort("$WRAP$"), [s], {})));
    }
  
    if (type[Tree] subgrammar := type(wrapped ? sort("$WRAP$") : s , grammar.definitions)) {
      result = parse(subgrammar, input, allowAmbiguity=true);
      return just(wrapped ? completeLocs(result.args[0]) : completeLocs(result));
    }        
  }
  catch ParseError(_) : ;
  catch value _ : ;

  return nothing();
}

bool isChar(char(_)) = true;
default bool isChar(Tree _) = false;

bool isLayout(appl(prod(layouts(_),_,_),_)) = true;
bool isLayout(appl(prod(label(_, layouts(_)),_,_),_)) = true;
default bool isLayout(Tree _) = false;

bool isLiteral(appl(prod(lit(_),_,_),_)) = true;
default bool isLiteral(Tree _) = false;

// anno int Tree@unique;
// Tree unique(Tree t) {
//    int secret = 0;
//    int unique() { secret += 1; return secret; };
//    return visit(t) { 
//      case Tree x => x[@unique=unique()] 
//    };
// }  

Tree completeLocs(Tree t:amb({Tree u,*_})) = nt when u@\loc?, <nt, _> := completeLocs(t, u@\loc.top, 0);
Tree completeLocs(Tree t:amb({Tree u,*_})) = nt when !(u@\loc?), <nt, _> := completeLocs(t, |unknown:///|(0,0), 0);
default Tree completeLocs(Tree t) = nt when t@\loc?, <nt, _> := completeLocs(t, t@\loc.top, 0);

tuple[Tree, int] completeLocs(Tree t, loc parent, int offset) {
  int s = offset;
  
  switch (t) {
    case char(_) : return <t[@\loc=parent(offset, 1)], offset + 1>;
    case amb(_)  : {
      newAlts = for (Tree a <- t.alternatives) {
        <a, s> = completeLocs(a, parent, offset);
        append a;
      }
      return <amb({*newAlts})[@\loc=parent(offset, s - offset)], s>;
    }
    case appl(p,_) : {
      newArgs = for (Tree a <- t.args) {
        <a, s> = completeLocs(a, parent, s);
        append a;
      }
      return <appl(p,newArgs)[@\loc=t@\loc?parent(offset, s - offset)], s>;
    }
    case cycle(_, _) : {
      return <t[@\loc=t@\loc?parent], offset>;
    }
    default:
      throw "unexected kind of tree <t>";
  } 
}

set[Symbol] sorts(type[&T <: Tree] grammar)
  = { delabel(s) | /Symbol s := grammar.definitions, isRegular(s) || s is lex || s is sort, !(s is empty)};
   
@synopsis{compute the depth of amb clusters as they are nested on top of each other.}
@description{
This function uses @memo to avoid exponential running times. If ambiguity clusters are nested,
then the size of the forest in memory is polynomial, even if an exponential number of trees are represented.
The algorithm counts on the structural equality of nested clusters as they are reached via different
paths of the parent clusters. If the number of elements in each cluster is bounded to 2 then
this count will be linear in the size of the cluster in memory, which means its a polynomial
in the length of the represented input string. Grammars with very long productions produce (much) longer
running times.
}   
@memo int ambNestingDepth(appl(_, list[Tree] args)) = (0 | max(it, ambNestingDepth(a)) | a <- args);
@memo int ambNestingDepth(amb(set[Tree] alts))      = (1 | max(it, 1 + ambNestingDepth(a)) | a <- alts);
@memo int ambNestingDepth(cycle(_,_)) = 0;
@memo int ambNestingDepth(char(_)) = 0;

@memo str format(Symbol s) = symbol2rascal(s);

@memo str format(Production p) = topProd2rascal(p);

@memo str format(type[Tree] grammar) = trim(grammar2rascal(Grammar::grammar({}, grammar.definitions)));
