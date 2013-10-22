
package hxfunc ;

enum Either<A,B>
{
	
	Left( x:A ) ;
	Right( y:B ) ;

}

class EitherUtils
{

	public static inline function isLeft<A,B>(e:Either<A,B>):Bool
	{
		return switch (e) {
			case Left(_): true ;
			case Right(_): false ;
		}
	}

	public static inline function isRight<A,B>(e:Either<A,B>):Bool
	{
		return switch (e) {
			case Left(_): false ;
			case Right(_): true ;
		}
	}

	public static inline function getLeft<A,B>(e:Either<A,B>):A
	{
		return switch (e) {
			case Left(x): x ;
			case Right(_): throw "illegal get Right on a Left object" ;
		}
	}

	public static inline function getRight<A,B>(e:Either<A,B>):B
	{
		return switch (e) {
			case Left(_): throw "illegal get Right on a Left object" ;
			case Right(y): y ;
		}
	}

}