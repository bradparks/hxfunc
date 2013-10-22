package hxfunc;

import haxe.ds.Option ;

class OptionUtils {

	public static inline function isDefined<T>(o:haxe.ds.Option<T>):Bool
	{

		return switch (o) {
			case Some(_): true ;
			case None:false ;
		}

	}

	public static inline function get<T>(o:haxe.ds.Option<T>):T
	{

		return switch (o) {
			case Some(x): x ;
			case None:throw "illegal get on None object" ;
		}

	}

	public static inline function map<T,U>(o:haxe.ds.Option<T>, f:T->U):Option<U>
	{

		if ( isDefined(o) )
			return Some( f( get(o) ) ) ;
		else
			return None ;

	}

	public static inline function or<T>(o:haxe.ds.Option<T>, els:T):T
	{

		if ( isDefined(o) )
			return get(o) ;
		else
			return els ;

	}

}