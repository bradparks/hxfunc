package hxfunc;

using utils.OptionUtils;

typedef PoolCell<T> = haxe.ds.Option<{
	data:T,
	next:PoolCell<T>
}>
class Pool<T:Poolable>
{

	private var storage:PoolCell<T> ;
	private var shells:PoolCell<T> ;
	private var factory:Void->T ;

	public var autoGrow:Int ;

	public function new( _factory )
	{
		storage = None ;
		shells = None ;
		factory = _factory ;
		autoGrow = 0 ;
	}

	public function get():T
	{
		if( storage.isDefined() )
			return unstack() ;
		else
			return create() ;
	}

	public function store( _x:T ){
		_x.reset() ;
		stack(_x) ;
	}

	public function grow( size:Int )
	{
		for( i in 0...size )
		{
			var x = factory() ;
			x.reset() ;
			stack( x ) ;
		}
	}

	inline private function create():T
	{
		if( autoGrow < 1 )
			throw "Imutable pool out of elements" ;
		else
		{
			grow( autoGrow ) ;
			return unstack() ;
		}
	}

	inline private function stack( _x:T )
	{

		var shell = getShell() ;
		shell.get().data = _x ;
		shell.get().next = storage ;
		storage = shell ;

	}

	/**
	 * Pre :  l is not None
	 */
	inline private function unstack():T
	{

		var shell = storage ;
		storage = shell.get().next ;

		var x = shell.get().data ;
		shell.get().data = null ;

		shell.get().next = shells ;
		shells = shell ;

		return x ;

	}

	inline private function getShell():PoolCell<T>
	{

		if( shells.isDefined() )
		{
			var shell = shells ;
			shells = shell.get().next ;
			shell.get().next = None ;
			return shell ;
		}
		else
			return Some({data:null,next:None}) ;

	}

}

interface Poolable
{
	function reset():Void ;
}