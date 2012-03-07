package  
{
	import cepa.utils.ToolTip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import pipwerks.SCORM;
	
	import cepa.utils.levenshteinDistance;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends Sprite
	{
		private var grafico:JanelaGrafico;
		
		private var orientacoesScreen:InstScreen;
		private var creditosScreen:AboutScreen;
		private var feedbackScreen:FeedBackScreen;
		
		/*
		 * Filtro de conversão para tons de cinza.
		 */
		private const GRAYSCALE_FILTER:ColorMatrixFilter = new ColorMatrixFilter([
			0.2225, 0.7169, 0.0606, 0, 0,
			0.2225, 0.7169, 0.0606, 0, 0,
			0.2225, 0.7169, 0.0606, 0, 0,
			0.0000, 0.0000, 0.0000, 1, 0
		]);
		
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.scrollRect = new Rectangle(0, 0, 700, 450);
			
			creditosScreen = new AboutScreen();
			addChild(creditosScreen);
			orientacoesScreen = new InstScreen();
			addChild(orientacoesScreen);
			feedbackScreen = new FeedBackScreen();
			addChild(feedbackScreen);
			
			initGrafico();
			addListeners();
			
			new_BTN.visible = false;
			ok_BTN.visible = true;
			
			botoes.resetButton.mouseEnabled = false;
			botoes.resetButton.filters = [GRAYSCALE_FILTER];
			botoes.resetButton.alpha = 0.5;
			
			stage.focus = inputAnswer;
			
			initLMSConnection();
		}
		
		private function initGrafico():void
		{
			grafico = new JanelaGrafico();
			addChild(grafico);
			
			setChildIndex(grafico, 0);
		}
		
		private function addListeners():void
		{
			new_BTN.addEventListener(MouseEvent.CLICK, nextExercise);
			ok_BTN.addEventListener(MouseEvent.CLICK, checkAnswer);
			inputAnswer.addEventListener(KeyboardEvent.KEY_UP, checkKey);
			
			botoes.tutorialBtn.addEventListener(MouseEvent.CLICK, iniciaTutorial);
			botoes.orientacoesBtn.addEventListener(MouseEvent.CLICK, openOrientacoes);
			botoes.resetButton.addEventListener(MouseEvent.CLICK, nextExercise);
			botoes.creditos.addEventListener(MouseEvent.CLICK, openCreditos);
			
			createToolTips();
		}
		
		private function checkKey(e:KeyboardEvent):void 
		{
			if (e.charCode == Keyboard.ENTER) {
				checkAnswer(null);
			}
		}
		
		private function openOrientacoes(e:MouseEvent):void 
		{
			orientacoesScreen.openScreen();
			setChildIndex(orientacoesScreen, numChildren - 1);
			setChildIndex(bordaAtividade, numChildren - 1);
		}
		
		private function openCreditos(e:MouseEvent):void 
		{
			creditosScreen.openScreen();
			setChildIndex(creditosScreen, numChildren - 1);
			setChildIndex(bordaAtividade, numChildren - 1);
		}
		
		private function createToolTips():void 
		{
			var infoTT:ToolTip = new ToolTip(botoes.creditos, "Créditos", 12, 0.8, 100, 0.6, 0.1);
			var instTT:ToolTip = new ToolTip(botoes.orientacoesBtn, "Orientações", 12, 0.8, 100, 0.6, 0.1);
			var resetTT:ToolTip = new ToolTip(botoes.resetButton, "Reiniciar", 12, 0.8, 100, 0.6, 0.1);
			var intTT:ToolTip = new ToolTip(botoes.tutorialBtn, "Reiniciar tutorial", 12, 0.8, 150, 0.6, 0.1);
			
			var finalizaTT:ToolTip = new ToolTip(ok_BTN, "Responder", 12, 0.8, 200, 0.6, 0.1);
			var newTT:ToolTip = new ToolTip(new_BTN, "Reiniciar", 12, 0.8, 250, 0.6, 0.1);
			
			addChild(infoTT);
			addChild(instTT);
			addChild(resetTT);
			addChild(intTT);
			
			addChild(finalizaTT);
			addChild(newTT);
		}
		
		private function nextExercise(e:MouseEvent):void 
		{
			grafico.addGraphFunction();
			inputAnswer.text = "";
			inputAnswer.mouseEnabled = true;
			new_BTN.visible = false;
			ok_BTN.visible = true;
			
			botoes.resetButton.mouseEnabled = false;
			botoes.resetButton.filters = [GRAYSCALE_FILTER];
			botoes.resetButton.alpha = 0.5;
			
			stage.focus = inputAnswer;
		}
		
		private function checkAnswer(e:MouseEvent):void 
		{
			stage.focus = null;
			var respostaDigitada:String = String(inputAnswer.text).toLowerCase();
			
			if (inputAnswer.text != "") {
				if (levenshteinDistance(respostaDigitada ,grafico.funcaoAtual) <= 1) {
					trace("acertou");
					feedbackScreen.setText("Parabéns!\nVocê acertou a função.");
				}else {
					trace("errou");
					feedbackScreen.setText("Veja o gráfico novamente e reveja sua resposta.");
				}
				
				lastScore = 100;
				completed = true
				save2LMS();
				
				new_BTN.visible = true;
				ok_BTN.visible = false;
				
				TextField(inputAnswer).mouseEnabled = false;
				
				botoes.resetButton.mouseEnabled = true;
				botoes.resetButton.filters = [];
				botoes.resetButton.alpha = 1;
			}
			else
			{
				trace("não respondido");
				feedbackScreen.setText("Digite o nome da função para verificar sua resposta.");
			}
			setChildIndex(feedbackScreen, numChildren - 1);
			setChildIndex(bordaAtividade, numChildren - 1);
			
		}
		
		
		//------------------------- Tutorial -----------------------------//
		
		
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		private var tutoSequence:Array = ["Estas placas de Petri contém três espécies distintas de bactérias.", 
										  "Classifique as bactérias arrastando os rótulos para as placas de Petri.",
										  "O tubo de ensaio contém um líquido propício à proliferação das três bactérias.",
										  "Esta escala indica a distribuição de oxigênio no tubo de ensaio: quanto mais verde, mais oxigênio há naquela altura do tubo.",
										  "Você pode arrastar uma ou mais bactérias para dentro do tubo de ensaio.",
										  "Pressione este botão para trocar o tubo de ensaio e começar uma nova experiência."];
		
		private function iniciaTutorial(e:MouseEvent = null):void 
		{
			tutoPos = 0;
			if(balao == null){
				balao = new CaixaTexto(true);
				addChild(balao);
				balao.visible = false;
				
				pointsTuto = 	[new Point(),
								new Point(),
								new Point(),
								new Point(),
								new Point(),
								new Point()];
								
				tutoBaloonPos = [[CaixaTexto.BOTTON, CaixaTexto.CENTER],
								[CaixaTexto.TOP, CaixaTexto.CENTER],
								[CaixaTexto.LEFT, CaixaTexto.FIRST],
								[CaixaTexto.LEFT, CaixaTexto.CENTER],
								[CaixaTexto.BOTTON, CaixaTexto.CENTER],
								[CaixaTexto.LEFT, CaixaTexto.LAST]];
			}
			balao.removeEventListener(Event.CLOSE, closeBalao);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(Event.CLOSE, closeBalao);
			balao.visible = true;
		}
		
		private function closeBalao(e:Event):void 
		{
			tutoPos++;
			if (tutoPos >= tutoSequence.length) {
				balao.removeEventListener(Event.CLOSE, closeBalao);
				balao.visible = false;
				//tutoPhase = false;
			}else {
				balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
				balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			}
		}
		
		
		//-------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		/* SCORM */
		
		private const PING_INTERVAL:Number = 5 * 60 * 1000; // 5 minutos
		
		//SCORM VARIABLES
		private var completed:Boolean;
		private var scorm:SCORM;
		private var scormTimeTry:String;
		private var connected:Boolean;
		private var score:int;
		private var pingTimer:Timer;
		private var lastTimes:int = 0;//quantas vezes ele ja fez
		private var lastScore:int = 0;//pontuação anterior
		private var maxTimes:int = 6;
		private var respondido:Boolean;
		
		
		/**
		 * @private
		 * Inicia a conexão com o LMS.
		 */
		private function initLMSConnection () : void
		{
			
			completed = false;
			connected = false;
			
			scorm = new SCORM();

			connected = scorm.connect();
			
			if (connected) {
 
				// Verifica se a AI já foi concluída.
				var status:String = scorm.get("cmi.completion_status");	
				
				switch(status)
				{
					// Primeiro acesso à AI// Continuando a AI...
					case "not attempted":
					case "unknown":
					default:
						completed = false;
						scormTimeTry = "times=0,points=0";
						score = 0;
						break;
					
					case "incomplete":
						completed = false;
						scormTimeTry = scorm.get("cmi.location");
						score = 0;
						break;
						
					// A AI já foi completada.
					case "completed"://Apartir desse momento os pontos nao serão mais acumulados
						completed = true;
						scormTimeTry = scorm.get("cmi.location");//Deve contar a quantidade de funções que ele fez e tambem média que ele tinha
						score = 0;
						//setMessage("ATENÇÃO: esta Atividade Interativa já foi completada. Você pode refazê-la quantas vezes quiser, mas não valerá nota.");
						break;
				}
				//Tratamento do scormTimeTry--------------------------------------------------------------------
				if (!completed)//Somente se a atividade nao estiver completa
				{
					var lista:Array = scormTimeTry.split(",");
					for(var i = 0; i < lista.length; i++)
					{
						if(i == 0)
						{
							lastTimes = int(lista[i].substr(lista[i].search("=") + 1));
							
						}else if(i == 1)
						{
							lastScore = int(lista[i].substr(lista[i].search("=") + 1));
							
						}
					}
				}
				
				//----------------------------------------------------------------------------------------------
				var success:Boolean = scorm.set("cmi.score.min", "0");
				if (success) success = scorm.set("cmi.score.max", "100");
				
				if (success)
				{
					scorm.save();
					if (pingTimer == null) {
						pingTimer = new Timer(PING_INTERVAL);
						pingTimer.start();
						pingTimer.addEventListener(TimerEvent.TIMER, pingLMS);
					}
				}
				else
				{
					//trace("Falha ao enviar dados para o LMS.");
					connected = false;
				}
			}
			else
			{
				//setMessage("Esta Atividade Interativa não está conectada a um LMS: seu aproveitamento nela NÃO será salvo.");
			}
			//reset();
		}
		
		/**
		 * @private
		 * Salva cmi.score.raw, cmi.location e cmi.completion_status no LMS
		 */ 
		private function save2LMS ()
		{
			if (connected)
			{
				// Salva no LMS a nota do aluno.
				lastScore = Math.max(0, Math.min(lastScore, 100));
				var success:Boolean = scorm.set("cmi.score.raw", (lastScore).toString());

				// Notifica o LMS que esta atividade foi concluída.
				success = scorm.set("cmi.completion_status", (completed ? "completed" : "incomplete"));

				// Salva no LMS o exercício que deve ser exibido quando a AI for acessada novamente.
				scormTimeTry = "times=" + lastTimes + ",points=" + lastScore;
				success = scorm.set("cmi.location", scormTimeTry);

				if (success)
				{
					scorm.save();
				}
				else
				{
					pingTimer.stop();
					//setMessage("Falha na conexão com o LMS.");
					connected = false;
				}
			}
		}
		
		/**
		 * @private
		 * Mantém a conexão com LMS ativa, atualizando a variável cmi.session_time
		 */
		private function pingLMS (event:TimerEvent)
		{
			scorm.get("cmi.completion_status");
		}
		//-------------------------------------------------------------------------------------------------------------------------------------------------------------
	}

}