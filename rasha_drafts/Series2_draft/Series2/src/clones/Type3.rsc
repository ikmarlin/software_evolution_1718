module clones::Type3
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Type;
import Node;
import Main;

alias identity = tuple[Symbol, str, int, list[value]]; 
data covertedAst = astNode(identity id, list[covertedAst] children);

int distance;

tuple[covertedAst,map[node,covertedAst]] convertAstNode(node subtree, map[node,covertedAst] store) {
	if (subtree in store) {
		return <store[subtree],store>;
	}
	list[value] props = [];
	list[node] children = [];
	for (c <- getChildren(subtree)) {
		switch (c) {
			case Declaration x: children += x;
			case Statement x: children += x;
			case Expression x: children += x;
			case list[Declaration] x: children += x;
			case list[Statement] x: children += x;
			case list[Expression] x: children += x;
			case value x: props += x;
		}
	}
	convertedChildren = [];
	for (c <- children) {
		<cs,store> = convertAstNode(c,store);
		convertedChildren += cs;
	}
	nn = astNode(<typeOf(subtree),getName(subtree),arity(subtree),props>,convertedChildren);
	store[subtree] = nn;
	return <nn,store>;
}