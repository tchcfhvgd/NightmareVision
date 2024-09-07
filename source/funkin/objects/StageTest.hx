package funkin.objects;

import flixel.group.FlxSpriteGroup;
import funkin.data.scripts.FunkinHScript;
import funkin.data.StageData.StageFile;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.objects.Stage.StageData;


//why is there 2 stagedata classes?
//anyway reason for this is cuz i never liked the idea of the charcters being apart of the states members and the bg/fg being in sub groups to layer
//just use insert or smth and if u need grouping u can make ur own groups // but i wanted to try a what if we put the chars inside the stage as well

class StageTest extends FlxTypedGroup<FlxBasic>
{
    var stageScript:FunkinHScript;

    public var boyfriendMap:Map<String,Character> = new Map();
    public var dadMap:Map<String,Character> = new Map();
    public var gfMap:Map<String,Character> = new Map();

    public var boyfriendGroup:FlxSpriteGroup;
    public var dadGroup:FlxSpriteGroup;
    public var gfGroup:FlxSpriteGroup;

    var boyfriend:Character;
    var gf:Character;
    var dad:Character;

    var _stageData:StageFile;

    public var curStage:String = 'stage';

    public function new(stagePath:String) 
    {
        _stageData = StageData.getStageFile(stagePath);
        if (_stageData == null) _stageData = StageData.template();

        curStage = stagePath;


        super();

        build();
    }


    public function build() 
    {
        gfGroup = new FlxSpriteGroup(_stageData.girlfriend[0], _stageData.girlfriend[1]);
        dadGroup = new FlxSpriteGroup(_stageData.opponent[0],_stageData.opponent[1]);
        boyfriendGroup = new FlxSpriteGroup(_stageData.boyfriend[0],_stageData.boyfriend[1]);
  
        add(gfGroup);
        add(dadGroup);
        add(boyfriendGroup);

        if (!_stageData.hide_girlfriend)
        {
            if(PlayState.SONG.gfVersion == null || PlayState.SONG.gfVersion.length < 1) PlayState.SONG.gfVersion = 'gf'; //Fix for the Chart Editor
            gf = new Character(0,0, PlayState.SONG.gfVersion);
            setCharPosition(gf);
            gf.scrollFactor.set(0.95, 0.95);
            gfGroup.add(gf);
        }

        dad = new Character(0,0,PlayState.SONG.player2);
        dadGroup.add(dad);
        dadMap.set(dad.curCharacter,dad);
        setCharPosition(dad,true);

        boyfriend = new Character(0,0,PlayState.SONG.player1,true);
        boyfriendGroup.add(boyfriend);
        boyfriendMap.set(boyfriend.curCharacter,boyfriend);
        setCharPosition(boyfriend);

    


        stageScript = findStageScript();
        
        if (stageScript != null) 
        {
            buildScript(stageScript);
        }

    }

    function findStageScript():Null<FunkinHScript> //honestly this should be a global func. culls through the types and finds it for you
    {

        final basePath:String = 'stages/' + curStage;

       //find stage script
        for (extension in FunkinHScript.exts) 
        {
            final file = '$basePath.$extension';

            for (i in [#if MODS_ALLOWED Paths.modFolders(file), #end Paths.getSharedPath(file)]) 
            {
                if (!FileSystem.exists(i)) continue;

                return FunkinHScript.fromFile(i);
            }
        }

        return null;
    }


    function buildScript(script:FunkinHScript) 
    {
        script.set('stage',this);

        script.set('add',this.add);
        script.set('insert',this.insert);
        script.set('remove',this.remove);

        script.set('dad',this.dad);
        script.set('boyfriend',this.boyfriend);
        script.set('gf',this.gf);

        script.set('addBehindDad',this.addBehindDad);
        script.set('addBehindBf',this.addBehindBf);
        script.set('addBehindGf',this.addBehindGf);

        script.call('onLoad');

        if (PlayState.instance != null) 
        {
            PlayState.instance.hscriptArray.push(script);
            PlayState.instance.funkyScripts.push(script);
        }
    }


    public function addBehindDad(obj:FlxBasic) 
    {
        insert(members.indexOf(dadGroup),obj);   
    }

    public function addBehindBf(obj:FlxBasic) 
    {
        insert(members.indexOf(boyfriendGroup),obj);
    }

    public function addBehindGf(obj:FlxBasic) 
    {
        insert(members.indexOf(gfGroup ?? boyfriendGroup),obj);
    }


    function setCharPosition(char:Character,gfCheck:Bool = false) 
    {
        if(gfCheck && char.curCharacter.startsWith('gf')) 
        { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(_stageData.girlfriend[0], _stageData.girlfriend[1]);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
    }



    //might replace with getters
    inline public function getBoyfriend() return boyfriend;
    inline public function getDad() return dad;
    inline public function getGF() return gf;


    
}

