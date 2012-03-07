package  
{
	import cepa.graph.DataStyle;
	import cepa.graph.GraphFunction;
	import cepa.graph.rectangular.SimpleGraph;
	import flash.display.Sprite;
	import cepa.utils.HumanRandom;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class JanelaGrafico extends Sprite
	{
		private const DISCONTINUITIES_SET_1:Vector.<Number> = Vector.<Number>([-2 * Math.PI, -Math.PI, 0, Math.PI, 2 * Math.PI]);
		private const DISCONTINUITIES_SET_2:Vector.<Number> = Vector.<Number>([ -3 * Math.PI / 2, - Math.PI / 2, Math.PI / 2, 3 * Math.PI / 2]);
		private const DISCONTINUITIES_SET_3:Vector.<Number> = new Vector.<Number>();
		
		private var graph:SimpleGraph;
		
		private var style:DataStyle;
		
		private var curvaAtual:String;
		
		private var sorteio:HumanRandom;
		private var funcoes:Array;
		private var funcaoGrafico:Function;
		private var graphFunction:GraphFunction;
		
		public function JanelaGrafico() 
		{
			//this.x = 20;
			this.y = 35;
			
			initFuncoes();
			
			configGraph();
			
			addGraphFunction();
		}
		
		private function initFuncoes():void
		{
			funcoes = ["seno", "cosseno", "tangente", "cotangente", "secante", "cossecante"];
			
			sorteio = new HumanRandom(funcoes);
		}
		
		private function configGraph():void
		{
			var xMin:Number = -Math.PI*2;
			var xMax:Number = Math.PI*2;
			var largura:Number = 700;
			var yMin:Number = -3;
			var yMax:Number = 3;
			var altura:Number = 340;
			
			graph = new SimpleGraph(xMin, xMax, largura, yMin, yMax, altura);
			graph.setTicksDistance(SimpleGraph.AXIS_X, 1);
			graph.setSubticksDistance(SimpleGraph.AXIS_X, 0.2);
			graph.setTicksDistance(SimpleGraph.AXIS_Y, 1);
			graph.setSubticksDistance(SimpleGraph.AXIS_Y, 0.2);
			
			//graph.x = 29;
			//graph.y = 1;
			
			graph.resolution = 1;
			
			this.addChild(graph);
			
			style = new DataStyle();
			style.color = 0xFF0000;
			
		}
		
		public function addGraphFunction():void
		{
			curvaAtual = sorteio.getItem();
			
			if (funcaoGrafico != null) {
				graph.removeFunction(graphFunction);
				funcaoGrafico = null;
				graphFunction = null;
				graph.draw();
			}
			
			funcaoGrafico = function (x:Number) : Number { return 0; };
			graphFunction = new GraphFunction( -Math.PI*2, Math.PI*2, funcaoGrafico);
			
			switch(curvaAtual) {
				case "seno":
					funcaoGrafico = function(xis:Number):Number {
						return Math.sin(xis);
					}
					
					graphFunction.discontinuities = DISCONTINUITIES_SET_3;
					break;
				case "cosseno":
					funcaoGrafico = function(xis:Number):Number {
						return Math.cos(xis);
					}
					
					graphFunction.discontinuities = DISCONTINUITIES_SET_3;
					break;
				case "tangente":
					funcaoGrafico = function(xis:Number):Number {
						return Math.tan(xis);
					}
					
					graphFunction.discontinuities = DISCONTINUITIES_SET_2;
					break;
				case "cotangente":
					funcaoGrafico = function(xis:Number):Number {
						if (Math.tan(xis) != 0 ) return 1 / Math.tan(xis);
						return Infinity;
					}
					
					graphFunction.discontinuities = DISCONTINUITIES_SET_1;
					break;
				case "secante":
					funcaoGrafico = function(xis:Number):Number {
						return 1 / Math.cos(xis);
					}
					graphFunction.discontinuities = DISCONTINUITIES_SET_2;
					break;
				case "cossecante":
					funcaoGrafico = function(xis:Number):Number {
						if (Math.sin(xis) != 0 ) return 1 / Math.sin(xis);
						else return Infinity;
					}
					graphFunction.discontinuities = DISCONTINUITIES_SET_1;
					break;
			}
			
			graphFunction.f = funcaoGrafico;
			
			graph.addFunction(graphFunction, style);
			graph.draw();
		}
		
		public function get funcaoAtual():String
		{
			return curvaAtual;
		}
	}

}