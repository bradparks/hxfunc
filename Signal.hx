package hxfunc;

import utils.Future;

class Signal<T>
{

	private var slots:Array<SlotType<T>> ;

	public function new(){
		slots = new Array() ;
	}

	public function add( f:T->Void, once:Bool = false )
	{
		slots.push( Slot_T(f,once) ) ;
	}

	public function addV( f:Void->Void, once:Bool = false )
	{
		slots.push( Slot_Void(f,once) ) ;
	}

	public function remove( f:T->Void )
	{
		for( s in slots )
			switch(s){
				case Slot_T(cb,_) : if (cb == f) slots.remove( s ) ;
				case Slot_Void(_,__) : continue ;
			}
	}

	public function removeV( f:Void->Void )
	{
		for( s in slots )
			switch(s){
				case Slot_Void(cb,_) : if (cb == f) slots.remove( s ) ;
				case Slot_T(_,__) : continue ;
			}
	}

	public function next():Future<T>
	{
		var f:Future<T> = new Future() ;
		add( f.complete, true ) ;
		return f ;
	}

	public function dispatch(_x:T = null)
	{
		for( s in slots )
		{
			switch( s ){
				case Slot_T(cb,once):
					cb(_x) ;
					if( once ) slots.remove(s) ;
				case Slot_Void(cb,once):
					cb() ;
					if( once ) slots.remove(s) ;
			}
		}
	}

}

enum SlotType<T> {
	Slot_Void(f:Void->Void, once:Bool) ;
	Slot_T(f:T->Void, once : Bool) ;
}