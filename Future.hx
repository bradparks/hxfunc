package hxfunc;

using utils.Either.EitherUtils ;
using utils.OptionUtils ;

/**
 * ...
 * @author Renaud Bardet
 */
class Future<T>
{
	
	private var result:haxe.ds.Option<Either<Dynamic,T>> ;

	public var callbacks:CallbackCell<T> ;
	
	public function new()
	{
		callbacks = TAIL ;
		result = None ;
	}

	public inline function isComplete():Bool
	{
		return result.isDefined() ;
	}

	public inline function onAvailable( f:T->Void ):Future<T>
	{
		if( isComplete() )
		{
			if ( result.get().isRight() ) f( result.get().getRight() ) ;
		}
		else
			callbacks = CELL( DATA(f), callbacks ) ;
		return this ;
	}

	public inline function onAvailableV( f:Void->Void ):Future<T>
	{
		if( isComplete() )
		{
			if ( result.get().isRight() ) f() ;
		}
		else
			callbacks = CELL( DATA_VOID(f), callbacks ) ;
		return this ;
	}

	public inline function onError( f:Dynamic->Void ):Future<T>
	{
		if( isComplete() )
		{
			if ( result.get().isLeft() ) f( result.get().getLeft() ) ;
		}
		else
			callbacks = CELL( ERROR(f), callbacks ) ;
		return this ;
	}

	public inline function onErrorV( f:Void->Void ):Future<T>
	{
		if( isComplete() )
		{
			if ( result.get().isLeft() ) f() ;
		}
		else
			callbacks = CELL( ERROR_VOID(f), callbacks ) ;
		return this ;
	}

	public inline function onResult( f:Either<Dynamic,T>->Void ):Future<T>
	{
		if( isComplete() )
			f( result.get() ) ;
		else
			callbacks = CELL( RESULT(f), callbacks ) ;
		return this ;
	}

	public inline function onResultV( f:Void->Void ):Future<T>
	{
		if( isComplete() )
			f() ;
		else
			callbacks = CELL( RESULT_VOID(f), callbacks ) ;
		return this ;
	}

	public function complete( _result:T = null ):Void
	{

		completeResult( Right( _result ) ) ;

	}

	public function fail( _error:Dynamic = null):Void
	{

		completeResult( Left( _error ) ) ;

	}

	public function completeResult( _result:Either<Dynamic,T> = null ):Void
	{

		if ( result.isDefined() )
			return ;

		result = Some( _result ) ;

		var cell = callbacks ;
		while( cell!=null )
		{
			switch (cell) {
				case CELL( cb, next ):
					switch (cb) {
						case DATA(f): if ( result.get().isRight() ) f( result.get().getRight() ) ;
						case DATA_VOID(f): if ( result.get().isRight() ) f() ;
						case ERROR(f): if ( result.get().isLeft() ) f( result.get().getLeft() ) ;
						case ERROR_VOID(f): if ( result.get().isLeft() ) f() ;
						case RESULT(f): f( result.get() ) ;
						case RESULT_VOID(f): f() ;
					}
					cell = next ;
				case TAIL:
					break ;
			}
		}

		callbacks = TAIL ;

	}

	public inline function map<U>( f:T->U ):Future<U>
	{
		var proxy = new Future<U>() ;
		onResult( 
			function(r){
				if ( r.isRight() )
					proxy.complete( f( r.getRight() ) ) ;
				else
					proxy.fail( r.getLeft() ) ;
			} ) ;
		return proxy ;
	}

	public inline function mapV<U>( f:Void->U ):Future<U>
	{
		var proxy = new Future<U>() ;
		onResult( 
			function(r){
				if ( r.isRight() )
					proxy.complete( f() ) ;
				else
					proxy.fail( r.getLeft() ) ;
			} ) ;
		return proxy ;
	}
	
	public inline function refine<U>( f:T->Either<Dynamic,U> ):Future<U>
	{
		var proxy = new Future<U>() ;
		onResult( function(r)
			if (r.isRight()) proxy.completeResult( f(r.getRight()) )
			else proxy.completeResult( Either.Left(r.getLeft()) )
		) ;
		return proxy ;
	}
	
	public inline function mapResult<U>( f:Either<Dynamic,T>->Either<Dynamic,U> ):Future<U>
	{
		var proxy = new Future<U>() ;
		onResult( function(r) proxy.completeResult( f(r) ) ) ;
		return proxy ;
	}

	public inline function chain<U>( f:T->Future<U> ):Future<U>
	{
		var proxy = new Future<U>() ;
		onAvailable(
			function(x)
			{
				f(x).onResult( proxy.completeResult ) ;
			} ) ;
		return proxy ;
	}
	
	public inline function chainV<U>( f:Void->Future<U> ):Future<U>
	{
		var proxy = new Future<U>() ;
		onAvailableV(
			function()
			{
				f().onResult( proxy.completeResult ) ;
			} ) ;
		return proxy ;
	}
	
	public inline function chainResult<U>( f:Either<Dynamic,T>->Future<U> ):Future<U>
	{
		var proxy = new Future<U>() ;
		onResult(
			function(r)
			{
				f(r).onResult( proxy.completeResult ) ;
			} ) ;
		return proxy ;
	}

	public inline function bind( f2:Future<T> ):Future<T>
	{

		f2.onResult( this.completeResult ) ;
		return this ;

	}

	public inline function join<U>(f2:Future<U>)
	{
		var proxy = new Future() ;
		function checkJoin()
		{
			if ( result.isDefined() && result.get().isRight() && f2.result.isDefined() && f2.result.get().isRight() )
				proxy.complete({_1:result.get().getRight(), _2:f2.result.get().getRight()}) ;
		}

		onAvailableV( checkJoin ) ;
		f2.onAvailableV( checkJoin ) ;
		onError( proxy.fail ) ;
		f2.onError( proxy.fail ) ;

		return proxy ;

	}

	public static inline function completed<T>( _x:T=null ):Future<T>
	{
		var f = new Future() ;
		f.complete(_x) ;
		return f ;
	}

}

enum CallbackCell<T>
{
	
	TAIL ;
	CELL( cb:CallbackType<T>, next:CallbackCell<T> ) ;
	
}

enum CallbackType<T>
{

	DATA( func:T->Void ) ;
	DATA_VOID( func:Void->Void ) ;

	ERROR( func:Dynamic->Void ) ;
	ERROR_VOID( func:Void->Void ) ;

	RESULT( func:Either<Dynamic,T>->Void ) ;
	RESULT_VOID( func:Void->Void ) ;
	
}