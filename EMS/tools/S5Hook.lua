--[[   //  S5Hook  //  by yoq  // v2.2
    
    S5Hook.Version                                              string, the currently loaded version of S5Hook
                                                                 
    S5Hook.Log(string textToLog)                                Writes the string textToLog into the Settlers5 logfile
                                                                 - In MyDocuments/DIE SIEDLER - DEdK/Temp/Logs/Game/XXXX.log
    
    S5Hook.ChangeString(string identifier, string newString)    Changes the string with the given identifier to newString
                                                                 - ex: S5Hook.ChangeString("names/pu_serf", "Minion")  --change pu_serf from names.xml

    S5Hook.ReloadCutscenes()                                    Reload the cutscenes in a usermap after a savegame load, the map archive must be loaded!
    
    S5Hook.LoadGUI(string pathToXML)                            Load a GUI definition from a .xml file.
                                                                 - call after AddArchive() for files inside the s5x archive
                                                                 - Completely replaces the old GUI --> Make sure all callbacks exist in the Lua script
                                                                 - Do NOT call this function in a GUI callback (button, chatinput, etc...)
                                                                 
    S5Hook.Eval(string luaCode)                                    Parses luaCode and returns a function, can be used to build a internal debugger
                                                                 - ex: myFunc = S5Hook.Eval("Message('Hello world')")
                                                                       myFunc()
                                                                       
    S5Hook.ReloadEntities()                                        Reloads all entity definitions, not the entities list -> only modifications are possible
                                                                 - In general: DO NOT USE, this can easily crash the game and requires extensive testing to get it right
                                                                 - Requires the map to be added with precedence
                                                                 - Only affects new entities -> reload map / reload savegame
                                                                 - To keep savegames working, it is only possible to make entities more complex (behaviour, props..)
                                                                   do not try to remove props/behaviours (ex: remove darios hawk), this breaks simple savegame loading
    
    S5Hook.SetSettlerMotivation(eID, motivation)                Set the motivation for a single settler (and only settlers, crashes otherwise ;)
                                                                 - motivation 1 = 100%, 0.2 = 20% settlers leaves
                                                                 
    S5Hook.GetWidgetPosition(widget)                            Gets the widget position relative to its parent
                                                                - return1: X
                                                                - return2: Y
                                                                
    S5Hook.GetWidgetSize(widget)                                Gets the size of the widget
                                                                - return1: width
                                                                - return2: height
                                                                
    S5Hook.IsValidEffect(effectID)                              Checks whether this effectID is a valid effect, returns a bool
    
    S5Hook.SetPreciseFPU()                                      Sets 53Bit precision on the FPU, allows accurate calculation in Lua with numbers exceeding 16Mil,
                                                                however most calls to engine functions will undo this. Therefore call directly before doing a calculation 
                                                                in Lua and don't call anything else until you're done.

    S5Hook.CreateProjectile(                                    Creates a projectile effect, returns an effectID, which can be used with Logic.DestroyEffect()
                            int effectType,         -- from the GGL_Effects table
                            float startX, 
                            float startY, 
                            float targetX, 
                            float targetY 
                            int damage = 0,         -- optional, neccessary to do damage
                            float radius = -1,      -- optional, neccessary for area hit
                            int targetId = 0,       -- optional, neccessary for single hit
                            int attackerId = 0,     -- optional, used for events & allies when doing area hits
                            fn hitCallback)         -- optional, fires once the projectile reaches the target, return true to cancel damage events
                            
                                                                Single-Hit Projectiles:
                                                                    FXArrow, FXCrossBowArrow, FXCavalryArrow, FXCrossBowCavalryArrow, FXBulletRifleman, FXYukiShuriken, FXKalaArrow

                                                                Area-Hit Projectiles:
                                                                    FXCannonBall, FXCannonTowerBall, FXBalistaTowerArrow, FXCannonBallShrapnel, FXShotRifleman
    
    
    S5Hook.GetTerrainInfo(x, y)                                 Fetches info from the HiRes terrain grid
                                                                 - return1: height (Z)
                                                                 - return2: blocking value, bitfield
                                                                 - return3: sector nr
                                                                 - return4: terrain type
                                                                 
    S5Hook.GetFontConfig(fontId)                                Returns the current font configuration (fontSize, zOffset, letterSpacing), or nil
    S5Hook.SetFontConfig(fontId, size, zOffset, spacing)        Store new configuration for this font

    Internal Filesystem: S5 uses an internal filesystem - whenever a file is needed it searches for the file in the first archive from the top, then the one below...
            | Map File (s5x)      |                             The Map File is only on top of the list during loading / savegame loading, and gets removed after            
            | extra2\bba\data.bba |                                GameCallback_OnGameStart (FirstMapAction) & Mission_OnSaveGameLoaded (OnSaveGameLoaded)
            | base\data.bba       |                             ( <= the list is longer than 3 entries, only for illustration)
            
            S5Hook.AddArchive([string filename])                Add a archive to the top of the filesystem, no argument needed to load current s5x
            S5Hook.RemoveArchive()                              Removes the top-most entry from the filesystem
                                                                 - ex: S5Hook.AddArchive(); S5Hook.LoadGUI("maps/externalmap/mygui.xml"); S5Hook.RemoveArchive()
            
    MusicFix: allows Music.Start() to use the internal file system
            S5Hook.PatchMusicFix()                                      Activate
            S5Hook.UnpatchMusicFix()                                    Deactivate
                                                                         - ex: crickets as background music on full volume in an endless loop
                                                                               S5Hook.PatchMusicFix()
                                                                               Music.Start("sounds/ambientsounds/crickets_rnd_1.wav", 127, true)
                                                                             
                            
    RuntimeStore: key/value store for strings across maps 
            S5Hook.RuntimeStore(string key, string value)                 - ex: S5Hook.RuntimeStore("addedS5X", "yes")
            S5Hook.RuntimeLoad(string key)                                 - ex: if S5Hook.RuntimeLoad("addedS5X") ~= "yes" then [...] end
                            
    CustomNames: individual names for entities
            S5Hook.SetCustomNames(table nameMapping)                    Activates the function
            S5Hook.RemoveCustomNames()                                  Stop displaying the names from the table
                                                                         - ex: cnTable = { ["dario"] = "Darios new Name", ["erec"] = "Erecs new Name" }
                                                                               S5Hook.SetCustomNames(cnTable)
                                                                               cnTable["thief1"] = "Pete"        -- works since cnTable is a reference
    KeyTrigger: Callback for ALL keys with KeyUp / KeyDown
            S5Hook.SetKeyTrigger(func callbackFn)                       Sets callbackFn as the callback for key events
            S5Hook.RemoveKeyTrigger()                                   Stop delivering events
                                                                         - ex: S5Hook.SetKeyTrigger(function (keyCode, keyIsUp)
                                                                                    Message(keyCode .. " is up: " .. tostring(keyIsUp))
                                                                               end)

    CharTrigger: Callback for pressed characters on keyboard
            S5Hook.SetCharTrigger(func callbackFn)                      Sets callbackFn as the callback for char events
            S5Hook.RemoveCharTrigger()                                  Stop delivering events
                                                                         - ex: S5Hook.SetCharTrigger(function (charAsNum)
                                                                                    Message("Pressed: " .. string.char(charAsNum))
                                                                               end)

    MemoryAccess: Direct access to game objects                         !!!DO NOT USE IF YOU DON'T KNOW WHAT YOU'RE DOING!!!
            S5Hook.GetEntityMem(int eID)                                Gets the address of a entity object
            S5Hook.GetRawMem(int ptr)                                   Gets a raw pointer
            val = obj[n]                                                Dereferences obj and returns a new address: *obj+4n
            shifted = obj:Offset(n)                                     Returns a new pointer, shifted by n: obj+4n
            val:GetInt(), val:GetFloat(), val:GetString()               Returns the value at the address
            val:SetInt(int newValue), val:SetFloat(float newValue)      Write the value at the address
            val:GetByte(offset), val:SetByte(offset, newValue)          Read or Write a single byte relative to val
            S5Hook.ReAllocMem(ptr, newSize)                             realloc(ptr, newSize), call with ptr==0 to use like malloc()
            S5Hook.FreeMem(ptr)                                         free(ptr)
                                                                         - ex: eObj = S5Hook.GetEntityMem(65537)
                                                                               speedFactor = eObj[31][1][7]:GetFloat()
                                                                               name = eObj[51]:GetString()
                                                                               
   EntityIterator: Fast iterator over all entities                      
            S5Hook.EntityIterator(...)                                  Takes 0 or more Predicate objects, returns an iterator over all matching eIDs
            S5Hook.EntityIteratorTableize(...)                          Takes 0 or more Predicate objects, returns a table with all matching eIDs
                Predicate.InCircle(x, y, r)                             Matches entities in the the circle at (x,y) with radius r
                Predicate.InRect(x0, y0, x1, y1)                        Matches entities with x between x0 and x1, and y between y0 and y1, no need to swap if x0 > x1
                Predicate.IsBuilding()                                  Matches buildings
                Predicate.InSector(sectorID)
                Predicate.OfPlayer(playerID)
                Predicate.OfType(entityTypeID)
                Predicate.OfCategory(entityCategoryID)
                Predicate.OfUpgradeCategory(upgradeCategoryID)
				Predicate.NotOfPlayer0()								Matches entities with a playerId other than 0
				Predicate.OfAnyPlayer(player1, player2, ...)			Matches entities of any of the specified players
				Predicate.OfAnyType(etyp1, etyp2, ...)					Matches entities with any of the specified entity types
				Predicate.ProvidesResource(resourceType)				Matches entities, where serfs can extract the specified resource. Use ResourceType.XXXRaw
                                                                        Notes: Use the iterator version if possible, it's usually faster for doing operations on every match.
                                                                               The Tableize version is just faster if you want to create a table and save it for later.
                                                                               Place the faster / more unlikely predicates in front for better performance!
                                                                        ex: Heal all military units of Player 1
                                                                            for eID in S5Hook.EntityIterator(Predicate.OfPlayer(1), Predicate.OfCategory(EntityCategories.Military)) do
                                                                                AddHealth(eID, 100);
                                                                            end
    
    CNetEvents: Access to the Settlers NetEvents, where Player input is handeled.
            S5Hook.SetNetEventTrigger(func)                             Sets a Trigger function, called every time a CNetEvent is created. Parameters are (memoryAccesToObject, eventId).
            S5Hook.RemoveNetEventTrigger()                              Removes the previously set NetEventTrigger.
            PostEvent                                                   Provides access to many Entity Orders, previously unavaialble in Lua.
    
    
    OnScreenInformation (OSI): 
        Draw additional info near entities into the 3D-View (like healthbar, etc).
        You have to set a trigger function, which will be responsible for drawing 
        all info EVERY frame, so try to write efficient code ;)
        
            S5Hook.OSILoadImage(string path)                            Loads a image and returns an image object
                                                                         - Images have to be reloaded after a savegame load
                                                                         - ex: imgObj = S5Hook.OSILoadImage("graphics\\textures\\gui\\onscreen_emotion_good")

            S5Hook.OSIGetImageSize(imgObj)                              Returns sizeX and sizeY of the given image
                                                                         - ex: sizeX, sizeY = S5Hook.OSIGetImageSize(imgObj)

            S5Hook.OSISetDrawTrigger(func callbackFn)                   callbackFn(eID, bool active, posX, posY) will be called EVERY frame for every 
                                                                           currently visible entity with overhead display, the active parameter become true
                                                                           
            S5Hook.OSIRemoveDrawTrigger()                               Stop delivering events

        Only call from the DrawTrigger callback:
            S5Hook.OSIDrawImage(imgObj, posX, posY, sizeX, sizeY)       Draw the image on the screen. Stretching is allowed.
            
            S5Hook.OSIDrawText(text, font, posX, posY, r, g, b, a)      Draw the string on the screen. Valid values for font range from 1-10.
                                                                        The color is specified by the r,g,b,a values (0-255).
                                                                        a = 255 is maximum visibility
                                                                        Standard S5 modifiers are allowed inside text (@center, etc...)
        Example:
        function SetupOSI()
            myImg = S5Hook.OSILoadImage("graphics\\textures\\gui\\onscreen_emotion_good")
            myImgW, myImgH = S5Hook.OSIGetImageSize(myImg)
            S5Hook.OSISetDrawTrigger(cbFn)
        end

        function cbFn(eID, active, x, y)
            if active then
                S5Hook.OSIDrawImage(myImg, x-myImgW/2, y-myImgH/2 - 40, myImgW, myImgH)
            else
                S5Hook.OSIDrawText("eID: " .. eID, 3, x+25, y, 255, 255, 128, 255)
            end
        end                                                        
    
    Set up with InstallS5Hook(), this needs to be called again after loading a savegame.
    S5Hook only works with the newest patch version of Settlers5, 1.06!
    S5Hook is available immediately, but check the return value, in case the player has a old patchversion.
]]

function InstallHook(installedCallback) -- for compatability with v0.10 or older 
    if InstallS5Hook() then installedCallback() end
end


function InstallS5Hook()
    if nil == string.find(Framework.GetProgramVersion(), "1.06.0217") then
        Message("Error: S5Hook requires version patch 1.06!")
        return false
    end
    
    if not __mem then __mem = {}; end
    __mem.__index = function(t, k) return __mem[k] or __mem.cr(t, k); end
    
    local loader     = { 4202752, 4258997, 0, 5809871, 6455758, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4199467, 7737432, 4761371, 4198400, 6598656, 64, 8743464, 4203043, 8731292, 7273523, 4199467, 5881260, 6246939, 6519628, 0, 3, 4203648, 6045570, 6037040, 4375289, 6519628, 6268672, 4199467, 6098484, 6281915, 6282334, 4659101, 10616832, 0, 0 }
    local S5HookData = "mpDkcAlabmAAfddfeigpgpglAfggfhchdgjgpgoAdccodcAcfhdKAcfhdfmcfhdcohddfhiAehbmkcAHffgogmgpgbgeAedbmkcAGechcgfgbglAnoEkcAOfagbhegdgienhfhdgjgdeggjhiAlaEkcAQffgohagbhegdgienhfhdgjgdeggjhiAmeFkcANepfdejemgpgbgeejgngbghgfAUGkcAQepfdejehgfheejgngbghgffdgjhkgfAekGkcANepfdejeehcgbhhejgngbghgfAkbGkcAMepfdejeehcgbhhfegfhiheApnGkcASepfdejfdgfheeehcgbhhfehcgjghghgfhcAcdHkcAVepfdejfcgfgngphggfeehcgbhhfehcgjghghgfhcAmkHkcANfchfgohegjgngffdhegphcgfAGIkcAMfchfgohegjgngfemgpgbgeAedIkcANedgigbgoghgffdhehcgjgoghAiaIkcAEemgpghAjnIkcALebgegeebhcgdgigjhggfALJkcAOfcgfgngphggfebhcgdgigjhggfAdlJkcAQfcgfgmgpgbgeedhfhehdgdgfgogfhdAgcJkcAIemgpgbgeehffejAicJkcAFefhggbgmAkjJkcAPfdgfheedhfhdhegpgneogbgngfhdAndJkcASfcgfgngphggfedhfhdhegpgneogbgngfhdAkbKkcAPfdgfheedgigbhcfehcgjghghgfhcAhbKkcASfcgfgngphggfedgigbhcfehcgjghghgfhcAdnLkcAOfdgfheelgfhjfehcgjghghgfhcANLkcARfcgfgngphggfelgfhjfehcgjghghgfhcApfLkcAUfdgfheengphfhdgfeegphhgofehcgjghghgfhcAllLkcAXfcgfgngphggfengphfhdgfeegphhgofehcgjghghgfhcAgoMkcAVfdgfhefdgfhehegmgfhcengphegjhggbhegjgpgoAldMkcAPfcgfgmgpgbgeefgohegjhegjgfhdApfMkcASehgfhefhgjgeghgfhefagphdgjhegjgpgoAbkNkcAOehgfhefhgjgeghgfhefdgjhkgfAhnNkcARedhcgfgbhegffahcgpgkgfgdhegjgmgfApiOkcAOejhdfggbgmgjgeefgggggfgdheAfoPkcAPehgfhefegfhchcgbgjgoejgogggpAeeRkcANehgfheefgohegjhehjengfgnAgmRkcAKehgfhefcgbhhengfgnANTkcALfcgfebgmgmgpgdengfgnAdjTkcAIeghcgfgfengfgnAFTkcAOfdgfhefahcgfgdgjhdgfegfaffAdaUkcAPefgohegjhehjejhegfhcgbhegphcAblVkcAXefgohegjhehjejhegfhcgbhegphcfegbgcgmgfgjhkgfAehYkcATebgegeechfgjgmgegjgoghffhaghhcgbgegfAnobkkcATfdgfheeogfheefhggfgohefehcgjghghgfhcAWblkcAWfcgfgngphggfeogfheefhggfgohefehcgjghghgfhcAliblkcAOehgfheeggpgoheedgpgogggjghAodblkcAOfdgfheeggpgoheedgpgogggjghAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAinimcehmpoppppilgbMidmeMgakapenpkbAiemahfSppVieShgAkdpanpkbAmgFpenpkbABilbnjmdkifAgiIAkcAgicjAkcAoigjAAAoiieYAAgiIAkcAfdoiAlklhppgiopnippppfdppViaShgAgiPAkcAfdoiojljlhppgiXAkcAfdoinoljlhppgkpnfdppVfeShgAgkpofdppVlaShgAidmeYlibpkkeaAmgAojmheaBpahbgbAlihgkkeaAmgAojmheaBlbhbgbAgbmcEAfgfhilheceMilhmceQgkAppdgidmgFfgPlgegppBmgfhfdoijgknlhppiddoAhfogfpfomcIAppheceEfdppVcaShgAidmeImcEAkbklDkcAifmahecckdkeUhgAmhFklDkcAAAAAmhFjoggejAilpaifpgggmhFkcggejAhehgdbmamdiddnklDkcAAhfchkbkeUhgAkdklDkcAmhFkeUhgAkhFkcAlijoggejAmgAojeamhAgojofiAmgeaEjadbmamdijmgifpgPifijgbkhppilheceIgaibomcmBAAijofilNiipaiiAilBffinfnEfdfgppfaUifmahefofgoihalfjoppflfapphfApphfEgiAnghgAgiABAAinhfIfgoifkhhlcppidmeYgkAfgkbMjpifApphaMppViiUhgAijmgifpghebmpphfEgkCfgppVUVhgAibmecmBAAijheceEgbojQgbkhppfaoifcoelcppfiibmecmBAAgbojhdgbkhppgkCppheceIppVcaVhgAifmaheHfaoicpoelcppfippcfklDkcAloppAAAfgfgfgfgidomQnjoinjfmceMnjoinjfmceInjoonjfmceEnjoonjbmcegkBfdppVmmShgAidmeIfagkcioiigdllkppfjijmboihfkdldppfafdppVmaShgAidmeIijnodbmaeamdidomIijofgkBfdppVnaShgAidmeIijmbffidmfEffoicbkeldppnjefpmnjefAoikhGAAoikcGAAidmeIliCAAAmdidomQijofgkCfdppVcaShgAgkDfdppVcaShgAgkEfdppVcaShgAgkFfdppVcaShgAnjfnMnjfnInjfnEnjfnAffgkAgkBfdppVnaShgAidmeIfaoimhgildppijmboimmgkldppidmedadbmamdidomQijofgkCfdppVcaShgAppeeceEidhmceEJhfopidmeInlfnMnlfnInlfnEnlfnAgkAgkAffgkAfanjbmcefanjbmcegkAfanlbmcegkBfdppVmmShgAidmeIfaoiglgildppijmboiokhaldppidmeQdbmamdgipanippppfdppVdeShgAkdkpDkcAidmeIlihlWfeAmgAojeamhAnnpaenAdbmamdkbkpDkcAifmahecofagipanippppfdppVdmShgAidmeMmhFhlWfeAffilomfgmhFhpWfeAfhilhnMmhFkpDkcAAAAAdbmamdffijoffgfhgailbnjmdkifAppdfkpDkcAgipanippppfdppVdiShgAilefMnleaeeoifnFAAdbmadiifHCAAPjfmafafdppVkiShgAilefInjeaEnjAoidnFAAoidiFAAgkAgkAgkEfdppVmiShgAgkAfdppVlaShgAidmecmgbojlgOlcppfgildfpanpkbAgkBfdppVmmShgAfafgppVfmShgAgkCfdppVmmShgAfafgppVfmShgAgipanippppfgppVfeShgAidmecifodbmamdfgildfpanpkbAgkBfdppVmmShgAfafgppVfmShgAgipanippppfgppVliShgAgkppfgppVmmShgAfafdppVfmShgAidmecifodbmaeamdgkCfdppVmmShgAidmeIfagkBfdppVmmShgAidmeIfaoimmgeldppifmafkfiheVilfeceomilfcYinUikfcfaoiKibllppfkfkijCdbmamdgkBfdppVmmShgAidmeIfagiblAkcAoinbhjlcppidmeIdbmamdgailfmceceibomABAAijofgkBfdoipklelhppifmahfdnilNgaopieAidhjcmQhcFilejYolDidmbYfbgiiijphhAgibpAkcAffoidgcelkppidmeQffinkniaAAAffilNiipaiiAilRppfcdaijoigkBfailNiipaiiAilRppfcYibmeABAAgbdbmamdgailfmceceildfiipaiiAilegIilAileaMgifidahgAfaoilhchlkppidmeIifmaheHijpbilRppfccigbdbmamdgkBfdppVmmShgAidmeIifmaheDfaolFgipmjphhAkbemdekaAilIilBppfaMdbmamdgagkAgkBfdppVmmShgAidmeIfaoifffkldppijmboiogfkldppgbdbmamdgkAgkBfdppVmmShgAidmeIfafaoiJUlkppijeeceEfdppVkeShgAidmeQdbmaeamdliRpjfdAmgAojmheaBpgQeoAmgeaonolgipanippppfdppVdeShgAkdldDkcAidmeIdbmamdkbldDkcAifmahecnfagipanippppfdppVdmShgAidmeMliRpjfdAmgAoimheaBGpfpoppmgeaonhemhFldDkcAAAAAdbmamdiliamiAAAifmaheelfhijmhilbnjmdkifAgkAfdppVlaShgAppdfldDkcAgipanippppfdppVdiShgAfhfdppVfmShgAgkpofdppVliShgAgkppfdppVmmShgAidmecmfpllAAAAdjnihfKoigjoflappojlcoolbppfjojkmoolbppkblhDkcAifmahecefagipanippppfdppVdmShgAidmeMmhFenhfeaApihaUAmhFlhDkcAAAAAdbmamdgipanippppfdppVdeShgAkdlhDkcAidmeIlienhfeaAmhAhcjfgbAdbmamdgailbnjmdkifAppdflhDkcAgipanippppfdppVdiShgAnleeceMnnfmcepiidomIfdppVmeShgAgkAgkAgkBfdppVmiShgAgkAfdppVlaShgAidmedagbojdmnllcppkbllDkcAifmahecefagipanippppfdppVdmShgAidmeMmhFhohfeaAknhcUAmhFllDkcAAAAAdbmamdgipanippppfdppVdeShgAkdllDkcAidmeIlihohfeaAmhAnnjfgbAdbmamdgaijmpilbnjmdkifAppdfllDkcAgipanippppfdppVdiShgAnleeceMnnfmcepiidomIfdppVmeShgAijpilbCpgpbiioafafdppVkiShgAgkAgkAgkCfdppVmiShgAgkAfdppVlaShgAidmedigbojhenmlcppkblpDkcAifmahecofagipanippppfdppVdmShgAidmeMmhFiokfffAmhegECmhFjckfffAAAAolmhFlpDkcAAAAAdbmamdgipanippppfdppVdeShgAkdlpDkcAidmeIliiokfffAmgAojeamhAiiggemAdbmamdmhegECAAAgailbnjmdkifAppdflpDkcAgipanippppfdppVdiShgAilefQnleaQnnfmcepiidomIfdppVmeShgAgkAgkAgkBfdppVmiShgAgkAfdppVlaShgAidmedagbojchjjldppgagkBfdoiKlblhppfaoidhbjlgppifmahecoiniileAAAllHdaBAfdfdijodfdidmdEfdoikeddlgppilhjQilhpEgkCfgppVcaShgAnjfpYidmeQgbdbmamdkbgaopieAiliafiCAAileaMfaoinainljppdbmamdgkBfdoieakbldppfaoijlhhldppijmboiihhmldppidmeImdnnfmcepiidomIfdppVmeShgAidmeMmdgailfmceceoimlppppppifmahedmnjeaYnjeaUoinfppppppoinappppppgbliCAAAmdgailfmceceoikgppppppifmaheXnjeacanjeabmoilappppppoiklppppppgbliCAAAmdgbdbmamdideaBYggmheaFolEmdlikhXfgAiahiFolhecdoiofppppppidmaRoinnppppppidmaRoinfppppppidmaRoimnppppppggmheaLifpgmdgailfmceceidomeiijofdbmaljeiAAAiieeNppejhfpjmhefAjieghhAfdppVlmShgAfoijmggkBoileAAAgkCoiknAAAgkDoikgAAAgkEoijpAAAgkFoijiAAAnjfncenjfncanjffbmnjfnUnjffYnjfnQnlfnEidooFheddgkGoihhAAAnlfndeeohecggkHoigkAAAnjfndieohecagkIoifnAAAnlfndaeoheTgkJoifaAAAnlfncmolHmhefdiAAialpffilNkmfnijAilBppfafmfaidooChibpilhecenmgipanippppfdppVdeShgAijegfiidmeIppdgoicgAAAijGnlEceoiinpoppppfiidmeeigbliBAAAmdppheceEfdppVcaShgAidmeImcEAfgilheceIgkdaoiDddlkppfpijhacmijmhljcmAAApdkemheacejgOkcAfomcEAgailbnjmdkifAfbpphbfigipanippppfdppVdiShgAppVdmShgAgkAgkBgkAfdppVmiShgAgkppfdppVkmShgAijmggkAfdppVlaShgAidmecmfjilBilhicmijdjfaoieibplkppfiifpghfGgbilBppgacegbilBgkBppQmdgailfmcecegkBfdoihmkolhppfailNeeibijAoikmjlknppPlgmafafdppVkiShgAidmeIgbliBAAAmdkbkmfnijAilhacegkBfdoigdkolhppnjfnAgkCfdoifikolhppnjfnEinenIffoineemlgpppphfMpphfIileoEoiphinkcppifmamdgailfmceceidomQijofoiljppppppPiejmAAAileobmilefMeaPkpebbmDefIilfbIineeecCPlhAfafdoifjkolhppkbomibifAileaYileiEilefMPkpFheilijADefIPlgEBfafdoidgkolhpppphfMpphfIoikbgelfppfafdoicekolhppfgkbkmfnijAileaceilhacaljEAAAilefIjjphpjfailefMjjphpjijmcecPkpfgcmfiBmcglncEileoIidmbEBnbPlgBfafdoiohknlhppfoidmeQgbliEAAAmdidmeQgbdbmamdhddfgmhfgbdfAgmhfgbfphdgfhegngfhegbhegbgcgmgfAgmhfgbfpgogfhhhfhdgfhcgegbhegbAgmhfgbemfpgfhchcgphcAgiWQkcAppVniQhgAgidoQkcAfagicoQkcAfagibnQkcAfappVniRhgAkdAnlkbAppVniRhgAkdEnlkbAppVniRhgAkdInlkbAmdifSkcAHehgfheejgoheAglSkcAJehgfheeggmgpgbheAkaSkcAIehgfheechjhegfAeoSkcAHfdgfheejgoheAdbSkcAJfdgfheeggmgpgbheAmgSkcAIfdgfheechjhegfAokSkcAKehgfhefdhehcgjgoghAofRkcADgdhcALSkcAHepgggghdgfheAAAAAfpfpgngfgnAhfhdgfcadkAgipnQkcAgiiiQkcAoifopdppppgipnQkcAfdoipkkmlhppgiopnippppfdppViaShgAgipanippppfdppVdeShgAkdmdDkcAidmeQmdgailfmcecegkBfdoidakmlhppfaoifnUlgppifmahfEgbdbmamdfaoicbAAAgbliBAAAmdgailfmcecegkBfdoiIkmlhppfaoiHAAAgbliBAAAmdilheceEgkIfdppVEnlkbAinfaEijQijdcolPilheceEgkEfdppVEnlkbAijdappdfmdDkcAgipanippppfdppVdiShgAgkpofdppVAnlkbAidmebmmcEAgkBfdoiolkllhppifmaheBmdgiDRkcAfdppVInlkbAgailfmceceoinnppppppildaildggkCfdoiigkllhppinEigfaoijippppppgbliBAAAmdgailfmceceoilhppppppildaildggkCfdoigakllhppinEigfaoifmppppppgbliBAAAmdgailfmceceoijbppppppildagkCfdoifekllhppnjbogbliAAAAmdgailfmceceoiheppppppildagkCfdoibpkllhppijGgbliAAAAmdgailfmceceoifhppppppilAnjAoigfpkppppgbliBAAAmdgailfmceceoidnppppppilAppdafdoifckllhppgbliBAAAmdgailfmceceoiccppppppildagkCfdoimnkklhppPlgEdafafdoicmkllhppgbliBAAAmdgailfmceceoipmpoppppildagkCfdoikhkklhppBmggkDfdoijnkklhppiiGgbdbmamdgailfmceceoinipoppppilAppdafdoibpkllhppgbliBAAAmdoiehhblkppdbmamdgailfmcecegkCfdoighkklhppfagkBfdoifokklhppfaoigkcolkppfjfjfafdoiljkklhppgbliBAAAmdgailfmcecegkBfdoidlkklhppfaoiobbklkppfjgbdbmamdfkVkcAJejgoedgjhcgdgmgfAkcVkcAHejgofcgfgdheAppVkcAJepggfagmgbhjgfhcAcgWkcAHepggfehjhagfAghWkcALepggedgbhegfghgphchjAioWkcASepggffhaghhcgbgegfedgbhegfghgphchjAenWkcALejhdechfgjgmgegjgoghAnmWkcAJejgofdgfgdhegphcADXkcANeogpheepggfagmgbhjgfhcdaAebXkcAMepggebgohjfagmgbhjgfhcAmeXkcAKepggebgohjfehjhagfAlfWkcARfahcgphggjgegfhdfcgfhdgphfhcgdgfAAAAAfahcgfgegjgdgbhegfAgiWUkcAgifbTkcAoiehpappppmdgafdppVlmShgAfjfappEceijmhinEifIAAAfafdppVEnlkbAijmgidmeImhGAAAAmheeloEAAAAifppheTfhfdppVhmShgAoienkjlhppijEloepolojgipdUkcAfdppVfiShgAidmeMijheceYgbliBAAAmdfgfhffilheceQildnfihfijAilgpEidmhYincmopDdodjophnckilehEifmaheboinfgEilKifmjhebofcilRfappfcEiemaileecepmfkheFidmcEolofidmhIolncdbmaolGilehEileaIidopQcldnfihfijAijdofnfpfomcEAgagioonippppfdoimakilhppfaoiinppppppifmaheOfafdoinlkilhppgbliBAAAmdgbdbmamdgaoiPppppppijmolpBAAAfdppVgiShgAidmeEfgoifkppppppifmaheXfafdoikikilhppfhgkpofdppVgeShgAidmeMeholnpgbliBAAAmdgagkBoidnopppppgkCoidgopppppgkDoicpopppppidomMijofnjfnAnjfnInjfnEgkQfdppVEnlkbAijmbidmeIpphfAinefEfaoiCiklfppidmeMgbliBAAAmdgagkBoipfooppppgkDoiooooppppgkCoiohooppppgkEoioaooppppidomQijofnlpbhcCnjmjnjfnEnjfnMnlpbhcCnjmjnjfnAnjfnIgkUfdppVEnlkbAijmbidmeIffidEceIffoiDijlfppidmeQgbliBAAAmdgagkIfdppVEnlkbAijmgidmeImhGAljhhAgkBfdoigfkhlhppijegEgbliBAAAmdgagkIfdppVEnlkbAijmgidmeImhGkagmhgAgkBfdoidokhlhppijegEgbliBAAAmdgagkEfdppVEnlkbAidmeImhAgmEhhAgbliBAAAmdgagkIfdppVEnlkbAijmgidmeImhGieeohhAgkBfdoipnkglhppijegEgbliBAAAmdgagkIfdppVEnlkbAijmgidmeImhGgehjhhAgkBfdoingkglhppijegEgbliBAAAmdgagkIfdppVEnlkbAijmgidmeImhGeepphgAgkBfdoikpkglhppijegEgbliBAAAmdgagkIfdppVEnlkbAijmgidmeImhGceclhhAgkBfdoiiikglhppijegEgbliBAAAmdgagkIfdppVEnlkbAijmgidmeIijdgmhegEccXkcAgbliBAAAmdgailfmceceilelYidpjAhfJgbliAAAAmcEAgbliBAAAmcEAgafdppVlmShgAflijmbfbglmaEidmaMfafdppVEnlkbAijmgidmeIfjijdgmhegEjbXkcAijeoIlkAAAAdjmkheUidmcBfcfbfcfdoippkflhppfjfkijeejgIoloigbliBAAAmdgailfmceceilflYliAAAAilfbIdjmcheNilfeibMdjndheOidmaBolomgbliAAAAmcEAgbliBAAAmcEAgafdppVlmShgAflijmbfbglmaEidmaMfafdppVEnlkbAijmgidmeIfjijdgmhegEUYkcAijeoIlkAAAAdjmkheUidmcBfcfbfcfdoihmkflhppfjfkijeejgIoloigbliBAAAmdgailfmceceilflQliAAAAilfbIdjmcheNilfeibMdjndheOidmaBolomgbliAAAAmcEAgbliBAAAmcEAgagkCfdoidbkflhppfagkBfdoicikflhppfaijmgilNkakdifAilejcigkBoifahjkippiliiYDAAijmpoimjcekjppinepcafgfeoibpinkkppmhABAAAmheaEAAAAfigbdbmamdojYkcADhihcAdibjkcADgfdcAhhbjkcADgfhaAlpbjkcACgfApdbjkcAEgfhagmAdcbkkcADgfgjAhbbkkcADgdhaAAAAAfpfpgfhggfgoheAginbYkcAgijfYkcAoiioolppppmdgailfmceceidomYijofmhefAbmGhhAmhefEbjQBAgkBfdoihikelhppijefIgkCfdoignkelhppijefMgkDoiibolppppnjfnQgkEoihholppppnjfnUffoiegeelappidmebmgbdbmamdgailfmceceidomQijofmhefAgannhgAgkBfdoidakelhppijefEgkCfdoicfkelhppijefIgkDfdoibkkelhppijefMffoiHeelappidmeUgbdbmamdgailfmceceidomUijofmhefAfannhgAgkBfdoipbkdlhppijefEgkCfdoiogkdlhppijefIgkDoipkokppppnjfnMgkEoipaokppppnjfnQffoilpedlappidmeYgbdbmamdgailfmceceidomMijofmhefAcigmhgAgkBfdoikjkdlhppijefEgkCfdoijokdlhppijefIffoiiledlappidmeQgbdbmamdgailfmceceidomQijofmhefAdigmhgAgkBfdoihfkdlhppijefEgkCfdoigkkdlhppijefIgkDfdoifpkdlhppijefMffoiemedlappidmeUgbdbmamdgailfmceceidomQijofmhefAeigmhgAgkBfdoidgkdlhppijefEgkCfdoiclkdlhppijefIgkDfdoicakdlhppijefMffoiNedlappidmeUgbdbmamdgailfmceceidomciijofmhefAomFhhAmhefEcpQBAgkBfdoipakclhppijefIgkCfdoiofkclhppijefMgkDfdoinkkclhppijefQgkEoiooojppppnjfnUilefUijefcagkFoinoojppppnjfnYilefYijefcemhefbmAAAAffoikaeclappidmecmgbdbmamdgaoidcAAAgipanippppfdppVdeShgAkdmhDkcAidmeIoicfdllappileaciilIilBkdmlDkcAmhBfhblkcAgbliAAAAmdgaiddnmhDkcAAhedaoipndklappileaciilIkbmlDkcAijBppdfmhDkcAgipanippppfdppVdmShgAidmeMmhFmhDkcAAAAAgbliAAAAmdgailbnjmdkifAppdfmhDkcAgipanippppfdppVdiShgAidmeMpphececioiKpgppppileececipphaEfdoigckclhppgkAgkAgkCfdppVmiShgAidmeQgbppcfmlDkcAgkBfdoinjkblhppfaoipphhldppijmboiShmldppifmamdgailfmceceoinoppppppheemnjeaMnjeaInjeaEoiRpbppppoiMpbppppoiHpbppppgbliDAAAmdgailfmcecegkCfdoikjkblhppgkDfdoikbkblhppgkEfdoijjkblhppoijlppppppheJnjfiMnjfiInjfiEgbdbmamdinlokeCAAgailbnjmdkifAoiemAAAgbojpjinjopplimakchcAgailbnjmdkifAoidfAAAgbojdiiojopppbdbmamdgaoicfAAAgiIAkcAfdoimfkblhppfdppVhaShgAgiopnippppfdppVfeShgAidmeMgbdbmamdoidjoippppoikhokppppoifconppppoiolonppppoiicooppppoiclopppppoiibpoppppmdoildpappppoikjpdppppoigepeppppoihgphppppoickpmppppmd"
    
    local shrink = function(cc)
        local o, i = {}, 1
        for n = 1, string.len(cc) do
            local b = string.byte(cc, n)
            if b >= 97 then n=n+1; b=16*(b-97)+string.byte(cc, n)-97; else b=b-65; end
            o[i] = string.char(b); i = i + 1
        end
        return table.concat(o)
    end
    
    Mouse.CursorHide()
    for i = 1, 37 do Mouse.CursorSet(i); end
    Mouse.CursorSet(10)
    Mouse.CursorShow() 
    
    local eID = Logic.CreateEntity(Entities.XD_Plant1, 0, 0, 0, 0)
    local d, w, r = {}, Logic.SetEntityScriptingValue, Logic.GetEntityScriptingValue
    for o, v in loader do 
        d[o] = r(eID, -59+o)
        if v ~= 0 then w(eID, -59+o, v); end
    end
    Logic.HeroSetActionPoints(eID, 7517305, shrink(S5HookData))
    for o, v in d do w(eID, -59+o, v); end
    Logic.DestroyEntity(eID)
    
    if S5Hook ~= nil then 
        S5HookEventSetup();
        return true;
    end
end

function S5HookEventSetup()
    PostEvent = {}
    function PostEvent.SerfExtractResource(eID, resourceType, posX, posY)   __event.xr(eID, resourceType, posX, posY); end
    function PostEvent.SerfConstructBuilding(serf_eID, building_eID)        __event.e2(69655, serf_eID, building_eID); end
    function PostEvent.SerfRepairBuilding(serf_eID, building_eID)           __event.e2(69656, serf_eID, building_eID); end
    function PostEvent.HeroSniperAbility(heroId, targetId)                  __event.e2(69705, heroId, targetId); end
    function PostEvent.HeroShurikenAbility(heroId, targetId)                __event.e2(69708, heroId, targetId); end
    function PostEvent.HeroConvertSettlerAbility(heroId, targetId)          __event.e2(69695, heroId, targetId); end
    function PostEvent.ThiefStealFrom(thiefId, buildingId)                  __event.e2(69699, thiefId, buildingId); end
    function PostEvent.ThiefCarryStolenStuffToHQ(thiefId, buildingId)       __event.e2(69700, thiefId, buildingId); end
    function PostEvent.ThiefSabotage(thiefId, buildingId)                   __event.e2(69701, thiefId, buildingId); end
    function PostEvent.ThiefDefuse(thiefId, kegId)                          __event.e2(69702, thiefId, kegId); end
    function PostEvent.ScoutBinocular(scoutId, posX, posY)                  __event.ep(69704, scoutId, posX, posY); end
    function PostEvent.ScoutPlaceTorch(scoutId, posX, posY)                 __event.ep(69706, scoutId, posX, posY); end
    function PostEvent.HeroPlaceBombAbility(heroId, posX, posY)             __event.ep(69668, heroId, posX, posY); end
    function PostEvent.LeaderBuySoldier(leaderId)                           __event.e(69644, leaderId); end
    function PostEvent.UpgradeBuilding(buildingId)                          __event.e(69640, buildingId); end
    function PostEvent.CancelBuildingUpgrade(buildingId)                    __event.e(69662, buildingId); end
    function PostEvent.ExpellSettler(entityId)                              __event.e(69647, entityId); end
    function PostEvent.BuySerf(buildingId)                                  __event.epl(69636, GetPlayer(buildingId), buildingId); end
    function PostEvent.SellBuilding(buildingId)                             __event.epl(69638, GetPlayer(buildingId), buildingId); end
    function PostEvent.FoundryConstructCannon(buildingId, entityType)       __event.ei(69684, buildingId, entityType); end
    function PostEvent.HeroPlaceCannonAbility(heroId, bottomType, topType, posX, posY)  __event.cp(heroId, bottomType, topType, posX, posY); end
    
end

entities2 =
{
    [1] = {
        [1] = {
            [1] = 65539,
            [2] = 4,
            [3] = {
                Y = 59100,
                X = 61700,
            },
            [4] = 0,
            [5] = "PB_Headquarters1",
        },
        [2] = {
            [1] = 66155,
            [2] = 609,
            [3] = {
                Y = 73321.203125,
                X = 27304.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [3] = {
            [1] = 66156,
            [2] = 609,
            [3] = {
                Y = 74440.1015625,
                X = 25592.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [4] = {
            [1] = 66157,
            [2] = 609,
            [3] = {
                Y = 73617.296875,
                X = 23626.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [5] = {
            [1] = 66158,
            [2] = 609,
            [3] = {
                Y = 72701.296875,
                X = 21649.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [6] = {
            [1] = 66159,
            [2] = 609,
            [3] = {
                Y = 71649.296875,
                X = 20520.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [7] = {
            [1] = 66160,
            [2] = 609,
            [3] = {
                Y = 73114.8984375,
                X = 27318.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [8] = {
            [1] = 66161,
            [2] = 609,
            [3] = {
                Y = 70876.3984375,
                X = 27940.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [9] = {
            [1] = 66162,
            [2] = 609,
            [3] = {
                Y = 69477.5,
                X = 28465.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [10] = {
            [1] = 66163,
            [2] = 609,
            [3] = {
                Y = 70202.5,
                X = 22925.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [11] = {
            [1] = 66164,
            [2] = 609,
            [3] = {
                Y = 68356.8984375,
                X = 23767.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [12] = {
            [1] = 66165,
            [2] = 609,
            [3] = {
                Y = 69269.3984375,
                X = 28887,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [13] = {
            [1] = 66166,
            [2] = 609,
            [3] = {
                Y = 68466.796875,
                X = 30381.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [14] = {
            [1] = 66167,
            [2] = 609,
            [3] = {
                Y = 69910.8984375,
                X = 31374.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [15] = {
            [1] = 66168,
            [2] = 609,
            [3] = {
                Y = 70064.5,
                X = 32382.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [16] = {
            [1] = 66169,
            [2] = 609,
            [3] = {
                Y = 67684.203125,
                X = 33881.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [17] = {
            [1] = 66170,
            [2] = 609,
            [3] = {
                Y = 66835.5,
                X = 32367,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [18] = {
            [1] = 66171,
            [2] = 609,
            [3] = {
                Y = 66709.1015625,
                X = 31042.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [19] = {
            [1] = 66172,
            [2] = 609,
            [3] = {
                Y = 64332.5,
                X = 30410.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [20] = {
            [1] = 66173,
            [2] = 609,
            [3] = {
                Y = 62702.19921875,
                X = 31203.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [21] = {
            [1] = 66174,
            [2] = 609,
            [3] = {
                Y = 61355.5,
                X = 33209.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [22] = {
            [1] = 66175,
            [2] = 609,
            [3] = {
                Y = 60948.80078125,
                X = 34148.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [23] = {
            [1] = 66176,
            [2] = 609,
            [3] = {
                Y = 58569.8984375,
                X = 34072.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [24] = {
            [1] = 66177,
            [2] = 609,
            [3] = {
                Y = 73321.203125,
                X = 49595.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [25] = {
            [1] = 66178,
            [2] = 609,
            [3] = {
                Y = 74440.1015625,
                X = 51307.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [26] = {
            [1] = 66179,
            [2] = 609,
            [3] = {
                Y = 73617.296875,
                X = 53273.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [27] = {
            [1] = 66180,
            [2] = 609,
            [3] = {
                Y = 72701.296875,
                X = 55250.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [28] = {
            [1] = 66181,
            [2] = 609,
            [3] = {
                Y = 71649.296875,
                X = 56379.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [29] = {
            [1] = 66182,
            [2] = 609,
            [3] = {
                Y = 73114.8984375,
                X = 49581.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [30] = {
            [1] = 66183,
            [2] = 609,
            [3] = {
                Y = 70876.3984375,
                X = 48959.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [31] = {
            [1] = 66184,
            [2] = 609,
            [3] = {
                Y = 69477.5,
                X = 48434.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [32] = {
            [1] = 66185,
            [2] = 609,
            [3] = {
                Y = 70202.5,
                X = 53974.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [33] = {
            [1] = 66186,
            [2] = 609,
            [3] = {
                Y = 68356.8984375,
                X = 53132.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [34] = {
            [1] = 66187,
            [2] = 609,
            [3] = {
                Y = 69269.3984375,
                X = 48013,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [35] = {
            [1] = 66188,
            [2] = 609,
            [3] = {
                Y = 68466.796875,
                X = 46518.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [36] = {
            [1] = 66189,
            [2] = 609,
            [3] = {
                Y = 69910.8984375,
                X = 45525.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [37] = {
            [1] = 66190,
            [2] = 609,
            [3] = {
                Y = 70064.5,
                X = 44517.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [38] = {
            [1] = 66191,
            [2] = 609,
            [3] = {
                Y = 67684.203125,
                X = 43018.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [39] = {
            [1] = 66192,
            [2] = 609,
            [3] = {
                Y = 66835.5,
                X = 44533,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [40] = {
            [1] = 66193,
            [2] = 609,
            [3] = {
                Y = 66709.1015625,
                X = 45857.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [41] = {
            [1] = 66194,
            [2] = 609,
            [3] = {
                Y = 64332.5,
                X = 46489.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [42] = {
            [1] = 66195,
            [2] = 609,
            [3] = {
                Y = 62702.19921875,
                X = 45696.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [43] = {
            [1] = 66196,
            [2] = 609,
            [3] = {
                Y = 61355.5,
                X = 43690.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [44] = {
            [1] = 66197,
            [2] = 609,
            [3] = {
                Y = 60948.80078125,
                X = 42751.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [45] = {
            [1] = 66198,
            [2] = 609,
            [3] = {
                Y = 58569.8984375,
                X = 42827.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [46] = {
            [1] = 66199,
            [2] = 609,
            [3] = {
                Y = 57289.5,
                X = 41218.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [47] = {
            [1] = 66200,
            [2] = 609,
            [3] = {
                Y = 56185.5,
                X = 38603.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [48] = {
            [1] = 66201,
            [2] = 609,
            [3] = {
                Y = 55661.30078125,
                X = 45364.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [49] = {
            [1] = 66202,
            [2] = 609,
            [3] = {
                Y = 53908.5,
                X = 43930.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [50] = {
            [1] = 66203,
            [2] = 609,
            [3] = {
                Y = 53062.30078125,
                X = 43035.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [51] = {
            [1] = 66204,
            [2] = 609,
            [3] = {
                Y = 54808.19921875,
                X = 46878.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [52] = {
            [1] = 66205,
            [2] = 609,
            [3] = {
                Y = 54322.30078125,
                X = 49061.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [53] = {
            [1] = 66206,
            [2] = 609,
            [3] = {
                Y = 53220.3984375,
                X = 49583.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [54] = {
            [1] = 66207,
            [2] = 609,
            [3] = {
                Y = 51430.3984375,
                X = 50545.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [55] = {
            [1] = 66208,
            [2] = 609,
            [3] = {
                Y = 51321,
                X = 52414.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [56] = {
            [1] = 66209,
            [2] = 609,
            [3] = {
                Y = 50314.19921875,
                X = 51146.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [57] = {
            [1] = 66210,
            [2] = 609,
            [3] = {
                Y = 52269,
                X = 53726.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [58] = {
            [1] = 66211,
            [2] = 609,
            [3] = {
                Y = 54638.8984375,
                X = 54658.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [59] = {
            [1] = 66212,
            [2] = 609,
            [3] = {
                Y = 56416.1015625,
                X = 54918.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [60] = {
            [1] = 66213,
            [2] = 609,
            [3] = {
                Y = 58502.19921875,
                X = 55403,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [61] = {
            [1] = 66214,
            [2] = 609,
            [3] = {
                Y = 62171.8984375,
                X = 55462.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [62] = {
            [1] = 66215,
            [2] = 609,
            [3] = {
                Y = 62857.30078125,
                X = 55617.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [63] = {
            [1] = 66216,
            [2] = 609,
            [3] = {
                Y = 63162.3984375,
                X = 54638.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [64] = {
            [1] = 66217,
            [2] = 609,
            [3] = {
                Y = 64824,
                X = 53720.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [65] = {
            [1] = 66218,
            [2] = 609,
            [3] = {
                Y = 67012.6015625,
                X = 52695.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [66] = {
            [1] = 66219,
            [2] = 609,
            [3] = {
                Y = 69805.296875,
                X = 53074.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [67] = {
            [1] = 66220,
            [2] = 609,
            [3] = {
                Y = 71606.703125,
                X = 54290.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [68] = {
            [1] = 66221,
            [2] = 609,
            [3] = {
                Y = 50279.1015625,
                X = 55799.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [69] = {
            [1] = 66222,
            [2] = 609,
            [3] = {
                Y = 49957.5,
                X = 57391,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [70] = {
            [1] = 66223,
            [2] = 609,
            [3] = {
                Y = 47818.8984375,
                X = 60686.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [71] = {
            [1] = 66224,
            [2] = 609,
            [3] = {
                Y = 50319.19921875,
                X = 61033.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [72] = {
            [1] = 66225,
            [2] = 609,
            [3] = {
                Y = 51761.1015625,
                X = 62833.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [73] = {
            [1] = 66226,
            [2] = 609,
            [3] = {
                Y = 53000,
                X = 64814.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [74] = {
            [1] = 66227,
            [2] = 609,
            [3] = {
                Y = 55273.1015625,
                X = 65089.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [75] = {
            [1] = 66228,
            [2] = 609,
            [3] = {
                Y = 57212.5,
                X = 66096.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [76] = {
            [1] = 66229,
            [2] = 609,
            [3] = {
                Y = 59720.6015625,
                X = 69491.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [77] = {
            [1] = 66230,
            [2] = 609,
            [3] = {
                Y = 52283.30078125,
                X = 65947.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [78] = {
            [1] = 66231,
            [2] = 609,
            [3] = {
                Y = 51555.19921875,
                X = 67300.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [79] = {
            [1] = 66232,
            [2] = 609,
            [3] = {
                Y = 50625.69921875,
                X = 67825,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [80] = {
            [1] = 66233,
            [2] = 609,
            [3] = {
                Y = 49892,
                X = 68772.796875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [81] = {
            [1] = 66234,
            [2] = 609,
            [3] = {
                Y = 47478.1015625,
                X = 67175.796875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [82] = {
            [1] = 66235,
            [2] = 609,
            [3] = {
                Y = 45453.8984375,
                X = 65962,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [83] = {
            [1] = 66236,
            [2] = 609,
            [3] = {
                Y = 42989.1015625,
                X = 65711.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [84] = {
            [1] = 66237,
            [2] = 609,
            [3] = {
                Y = 41002.8984375,
                X = 65610.203125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [85] = {
            [1] = 66238,
            [2] = 609,
            [3] = {
                Y = 39204.69921875,
                X = 65508.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [86] = {
            [1] = 66239,
            [2] = 609,
            [3] = {
                Y = 57289.5,
                X = 35681.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [87] = {
            [1] = 66240,
            [2] = 609,
            [3] = {
                Y = 52414.6015625,
                X = 40600.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [88] = {
            [1] = 66241,
            [2] = 609,
            [3] = {
                Y = 51337.80078125,
                X = 39033.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [89] = {
            [1] = 66242,
            [2] = 609,
            [3] = {
                Y = 48304.8984375,
                X = 38534,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [90] = {
            [1] = 66243,
            [2] = 609,
            [3] = {
                Y = 45405,
                X = 38769.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [91] = {
            [1] = 66244,
            [2] = 609,
            [3] = {
                Y = 43033.80078125,
                X = 38722.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [92] = {
            [1] = 66245,
            [2] = 609,
            [3] = {
                Y = 40866.19921875,
                X = 38759.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [93] = {
            [1] = 66246,
            [2] = 609,
            [3] = {
                Y = 38945.80078125,
                X = 38987,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [94] = {
            [1] = 66247,
            [2] = 609,
            [3] = {
                Y = 38696.3984375,
                X = 40556.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [95] = {
            [1] = 66248,
            [2] = 609,
            [3] = {
                Y = 47894.19921875,
                X = 49960.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [96] = {
            [1] = 66249,
            [2] = 609,
            [3] = {
                Y = 45995.30078125,
                X = 50764.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [97] = {
            [1] = 66250,
            [2] = 609,
            [3] = {
                Y = 43972.19921875,
                X = 50868,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [98] = {
            [1] = 66251,
            [2] = 609,
            [3] = {
                Y = 42413.5,
                X = 49450,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [99] = {
            [1] = 66252,
            [2] = 609,
            [3] = {
                Y = 40189.69921875,
                X = 49393.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [100] = {
            [1] = 66253,
            [2] = 609,
            [3] = {
                Y = 56185.5,
                X = 38296.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [101] = {
            [1] = 66254,
            [2] = 609,
            [3] = {
                Y = 55661.30078125,
                X = 31535.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [102] = {
            [1] = 66255,
            [2] = 609,
            [3] = {
                Y = 53908.5,
                X = 32969.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [103] = {
            [1] = 66256,
            [2] = 609,
            [3] = {
                Y = 53062.30078125,
                X = 33864.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [104] = {
            [1] = 66257,
            [2] = 609,
            [3] = {
                Y = 54808.19921875,
                X = 30021.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [105] = {
            [1] = 66258,
            [2] = 609,
            [3] = {
                Y = 54322.30078125,
                X = 27838.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [106] = {
            [1] = 66259,
            [2] = 609,
            [3] = {
                Y = 75965.703125,
                X = 44337.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [107] = {
            [1] = 66260,
            [2] = 609,
            [3] = {
                Y = 74901.5,
                X = 47287.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [108] = {
            [1] = 66261,
            [2] = 609,
            [3] = {
                Y = 75731.6015625,
                X = 42011.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [109] = {
            [1] = 66262,
            [2] = 609,
            [3] = {
                Y = 64076,
                X = 52322.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [110] = {
            [1] = 66263,
            [2] = 609,
            [3] = {
                Y = 69766.796875,
                X = 59496.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [111] = {
            [1] = 66264,
            [2] = 609,
            [3] = {
                Y = 67701.796875,
                X = 61680.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [112] = {
            [1] = 66265,
            [2] = 609,
            [3] = {
                Y = 66380.1015625,
                X = 63693.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [113] = {
            [1] = 66266,
            [2] = 609,
            [3] = {
                Y = 49390.6015625,
                X = 40947.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [114] = {
            [1] = 66267,
            [2] = 609,
            [3] = {
                Y = 45474,
                X = 41106.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [115] = {
            [1] = 66268,
            [2] = 609,
            [3] = {
                Y = 46052.6015625,
                X = 44989.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [116] = {
            [1] = 66269,
            [2] = 609,
            [3] = {
                Y = 42019.8984375,
                X = 43137.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [117] = {
            [1] = 66270,
            [2] = 609,
            [3] = {
                Y = 40883.6015625,
                X = 41755.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [118] = {
            [1] = 66271,
            [2] = 609,
            [3] = {
                Y = 41107.1015625,
                X = 46083,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [119] = {
            [1] = 66272,
            [2] = 609,
            [3] = {
                Y = 43352.1015625,
                X = 47819.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [120] = {
            [1] = 66273,
            [2] = 609,
            [3] = {
                Y = 46282.80078125,
                X = 49108.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [121] = {
            [1] = 66274,
            [2] = 609,
            [3] = {
                Y = 53220.3984375,
                X = 27316.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [122] = {
            [1] = 66275,
            [2] = 609,
            [3] = {
                Y = 51430.3984375,
                X = 26354.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [123] = {
            [1] = 66276,
            [2] = 609,
            [3] = {
                Y = 38451.19921875,
                X = 55807.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [124] = {
            [1] = 66277,
            [2] = 609,
            [3] = {
                Y = 42840.69921875,
                X = 58526.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [125] = {
            [1] = 66278,
            [2] = 609,
            [3] = {
                Y = 42267.6015625,
                X = 60096.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [126] = {
            [1] = 66279,
            [2] = 609,
            [3] = {
                Y = 42340.30078125,
                X = 63540.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [127] = {
            [1] = 66280,
            [2] = 609,
            [3] = {
                Y = 51321,
                X = 24485.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [128] = {
            [1] = 66281,
            [2] = 609,
            [3] = {
                Y = 40171.30078125,
                X = 67444.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [129] = {
            [1] = 66282,
            [2] = 609,
            [3] = {
                Y = 42416.3984375,
                X = 69903.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [130] = {
            [1] = 66283,
            [2] = 609,
            [3] = {
                Y = 44508.8984375,
                X = 70804.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [131] = {
            [1] = 66284,
            [2] = 609,
            [3] = {
                Y = 44918.80078125,
                X = 73589.296875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [132] = {
            [1] = 66285,
            [2] = 609,
            [3] = {
                Y = 44781.3984375,
                X = 75360.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [133] = {
            [1] = 66286,
            [2] = 609,
            [3] = {
                Y = 42444.69921875,
                X = 75928.296875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [134] = {
            [1] = 66287,
            [2] = 609,
            [3] = {
                Y = 50314.19921875,
                X = 25753.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [135] = {
            [1] = 66288,
            [2] = 609,
            [3] = {
                Y = 49496.3984375,
                X = 74626.203125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [136] = {
            [1] = 66289,
            [2] = 609,
            [3] = {
                Y = 50651.3984375,
                X = 69346.203125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [137] = {
            [1] = 66290,
            [2] = 609,
            [3] = {
                Y = 70097.203125,
                X = 40713.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [138] = {
            [1] = 66291,
            [2] = 609,
            [3] = {
                Y = 71599.5,
                X = 46451.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [139] = {
            [1] = 66292,
            [2] = 609,
            [3] = {
                Y = 64924,
                X = 43873.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [140] = {
            [1] = 66293,
            [2] = 609,
            [3] = {
                Y = 67745.5,
                X = 49493.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [141] = {
            [1] = 66294,
            [2] = 609,
            [3] = {
                Y = 67336.296875,
                X = 57301.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [142] = {
            [1] = 66295,
            [2] = 609,
            [3] = {
                Y = 63171.8984375,
                X = 59198.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [143] = {
            [1] = 66296,
            [2] = 609,
            [3] = {
                Y = 61485.30078125,
                X = 63324.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [144] = {
            [1] = 66298,
            [2] = 609,
            [3] = {
                Y = 55771.5,
                X = 62491.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [145] = {
            [1] = 66299,
            [2] = 609,
            [3] = {
                Y = 52333.19921875,
                X = 69705.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [146] = {
            [1] = 66300,
            [2] = 609,
            [3] = {
                Y = 49950.3984375,
                X = 71124.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [147] = {
            [1] = 66301,
            [2] = 609,
            [3] = {
                Y = 46544.80078125,
                X = 68967.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [148] = {
            [1] = 66302,
            [2] = 609,
            [3] = {
                Y = 46702.1015625,
                X = 56187.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [149] = {
            [1] = 66303,
            [2] = 609,
            [3] = {
                Y = 44024.69921875,
                X = 54692.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [150] = {
            [1] = 66304,
            [2] = 609,
            [3] = {
                Y = 46739.6015625,
                X = 52529.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [151] = {
            [1] = 66305,
            [2] = 609,
            [3] = {
                Y = 51851.6015625,
                X = 48147.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [152] = {
            [1] = 66306,
            [2] = 609,
            [3] = {
                Y = 52924.69921875,
                X = 46091.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [153] = {
            [1] = 66307,
            [2] = 609,
            [3] = {
                Y = 50206.80078125,
                X = 45745.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [154] = {
            [1] = 66308,
            [2] = 609,
            [3] = {
                Y = 48816.1015625,
                X = 47843.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [155] = {
            [1] = 66309,
            [2] = 609,
            [3] = {
                Y = 52649.5,
                X = 44198.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [156] = {
            [1] = 66310,
            [2] = 609,
            [3] = {
                Y = 73383.203125,
                X = 38632.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [157] = {
            [1] = 66311,
            [2] = 609,
            [3] = {
                Y = 62769.19921875,
                X = 41018.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [158] = {
            [1] = 66312,
            [2] = 609,
            [3] = {
                Y = 52269,
                X = 23173.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [159] = {
            [1] = 66314,
            [2] = 609,
            [3] = {
                Y = 60593.19921875,
                X = 46591.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [160] = {
            [1] = 66315,
            [2] = 609,
            [3] = {
                Y = 60630.19921875,
                X = 50887.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [161] = {
            [1] = 66316,
            [2] = 609,
            [3] = {
                Y = 57034.6015625,
                X = 48131.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [162] = {
            [1] = 66317,
            [2] = 609,
            [3] = {
                Y = 56606.6015625,
                X = 51628.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [163] = {
            [1] = 66318,
            [2] = 609,
            [3] = {
                Y = 53916.5,
                X = 56850.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [164] = {
            [1] = 66319,
            [2] = 609,
            [3] = {
                Y = 52063.80078125,
                X = 59160.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [165] = {
            [1] = 66320,
            [2] = 609,
            [3] = {
                Y = 53204.6015625,
                X = 61898.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [166] = {
            [1] = 66321,
            [2] = 609,
            [3] = {
                Y = 61435.30078125,
                X = 67399.203125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [167] = {
            [1] = 66322,
            [2] = 609,
            [3] = {
                Y = 56231.69921875,
                X = 70671.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [168] = {
            [1] = 66323,
            [2] = 609,
            [3] = {
                Y = 53569.6015625,
                X = 72276.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [169] = {
            [1] = 66324,
            [2] = 609,
            [3] = {
                Y = 41327.3984375,
                X = 52706.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [170] = {
            [1] = 66325,
            [2] = 609,
            [3] = {
                Y = 48347.6015625,
                X = 63942.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [171] = {
            [1] = 66326,
            [2] = 609,
            [3] = {
                Y = 54906.8984375,
                X = 40789.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [172] = {
            [1] = 66327,
            [2] = 609,
            [3] = {
                Y = 71563.296875,
                X = 51883.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [173] = {
            [1] = 66328,
            [2] = 609,
            [3] = {
                Y = 58856.80078125,
                X = 65286.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [174] = {
            [1] = 66329,
            [2] = 609,
            [3] = {
                Y = 57056.69921875,
                X = 67636.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [175] = {
            [1] = 66330,
            [2] = 609,
            [3] = {
                Y = 68848.5,
                X = 43657.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [176] = {
            [1] = 66337,
            [2] = 609,
            [3] = {
                Y = 54638.8984375,
                X = 22241.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [177] = {
            [1] = 66338,
            [2] = 609,
            [3] = {
                Y = 56416.1015625,
                X = 21981.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [178] = {
            [1] = 66343,
            [2] = 609,
            [3] = {
                Y = 58502.19921875,
                X = 21497,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [179] = {
            [1] = 66344,
            [2] = 609,
            [3] = {
                Y = 62171.8984375,
                X = 21437.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [180] = {
            [1] = 66345,
            [2] = 609,
            [3] = {
                Y = 62857.30078125,
                X = 21282.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [181] = {
            [1] = 66350,
            [2] = 609,
            [3] = {
                Y = 63162.3984375,
                X = 22261.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [182] = {
            [1] = 66351,
            [2] = 609,
            [3] = {
                Y = 64824,
                X = 23179.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [183] = {
            [1] = 66366,
            [2] = 609,
            [3] = {
                Y = 67012.6015625,
                X = 24204.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [184] = {
            [1] = 66367,
            [2] = 609,
            [3] = {
                Y = 69805.296875,
                X = 23825.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [185] = {
            [1] = 66376,
            [2] = 609,
            [3] = {
                Y = 71606.703125,
                X = 22609.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [186] = {
            [1] = 66377,
            [2] = 609,
            [3] = {
                Y = 50279.1015625,
                X = 21100.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [187] = {
            [1] = 66380,
            [2] = 609,
            [3] = {
                Y = 49957.5,
                X = 19509,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [188] = {
            [1] = 66381,
            [2] = 609,
            [3] = {
                Y = 47818.8984375,
                X = 16213.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [189] = {
            [1] = 66386,
            [2] = 609,
            [3] = {
                Y = 50319.19921875,
                X = 15866.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [190] = {
            [1] = 66387,
            [2] = 609,
            [3] = {
                Y = 51761.1015625,
                X = 14066.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [191] = {
            [1] = 66415,
            [2] = 167,
            [3] = {
                Y = 57503,
                X = 62807.26953125,
            },
            [4] = 192.999984741211,
            [5] = "PU_Serf",
        },
        [192] = {
            [1] = 66431,
            [2] = 609,
            [3] = {
                Y = 53000,
                X = 12085.7998046875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [193] = {
            [1] = 66432,
            [2] = 609,
            [3] = {
                Y = 55273.1015625,
                X = 11810.7998046875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [194] = {
            [1] = 66434,
            [2] = 609,
            [3] = {
                Y = 57212.5,
                X = 10803.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [195] = {
            [1] = 66437,
            [2] = 609,
            [3] = {
                Y = 59720.6015625,
                X = 7408.10205078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [196] = {
            [1] = 66438,
            [2] = 609,
            [3] = {
                Y = 52283.30078125,
                X = 10952.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [197] = {
            [1] = 66439,
            [2] = 609,
            [3] = {
                Y = 51555.19921875,
                X = 9599.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [198] = {
            [1] = 66440,
            [2] = 609,
            [3] = {
                Y = 50625.69921875,
                X = 9075,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [199] = {
            [1] = 66441,
            [2] = 609,
            [3] = {
                Y = 49892,
                X = 8127.203125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [200] = {
            [1] = 66442,
            [2] = 609,
            [3] = {
                Y = 47478.1015625,
                X = 9724.203125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [201] = {
            [1] = 66443,
            [2] = 609,
            [3] = {
                Y = 45453.8984375,
                X = 10938,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [202] = {
            [1] = 66444,
            [2] = 609,
            [3] = {
                Y = 42989.1015625,
                X = 11188.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [203] = {
            [1] = 66446,
            [2] = 609,
            [3] = {
                Y = 41002.8984375,
                X = 11289.7998046875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [204] = {
            [1] = 66447,
            [2] = 609,
            [3] = {
                Y = 39204.69921875,
                X = 11391.7998046875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [205] = {
            [1] = 66448,
            [2] = 609,
            [3] = {
                Y = 52414.6015625,
                X = 36299.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [206] = {
            [1] = 66449,
            [2] = 609,
            [3] = {
                Y = 51337.80078125,
                X = 37866.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [207] = {
            [1] = 66450,
            [2] = 609,
            [3] = {
                Y = 48304.8984375,
                X = 38366,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [208] = {
            [1] = 66451,
            [2] = 609,
            [3] = {
                Y = 45405,
                X = 38130.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [209] = {
            [1] = 66452,
            [2] = 609,
            [3] = {
                Y = 43033.80078125,
                X = 38177.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [210] = {
            [1] = 66453,
            [2] = 609,
            [3] = {
                Y = 40866.19921875,
                X = 38140.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [211] = {
            [1] = 66454,
            [2] = 609,
            [3] = {
                Y = 38945.80078125,
                X = 37913,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [212] = {
            [1] = 66455,
            [2] = 609,
            [3] = {
                Y = 38696.3984375,
                X = 36343.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [213] = {
            [1] = 66456,
            [2] = 609,
            [3] = {
                Y = 47894.19921875,
                X = 26939.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [214] = {
            [1] = 66457,
            [2] = 609,
            [3] = {
                Y = 45995.30078125,
                X = 26135.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [215] = {
            [1] = 66458,
            [2] = 609,
            [3] = {
                Y = 43972.19921875,
                X = 26032,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [216] = {
            [1] = 66459,
            [2] = 609,
            [3] = {
                Y = 42413.5,
                X = 27450,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [217] = {
            [1] = 66460,
            [2] = 609,
            [3] = {
                Y = 40189.69921875,
                X = 27506.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [218] = {
            [1] = 66461,
            [2] = 609,
            [3] = {
                Y = 75965.703125,
                X = 32562.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [219] = {
            [1] = 66462,
            [2] = 609,
            [3] = {
                Y = 74901.5,
                X = 29612.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [220] = {
            [1] = 66463,
            [2] = 609,
            [3] = {
                Y = 75731.6015625,
                X = 34888.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [221] = {
            [1] = 66464,
            [2] = 609,
            [3] = {
                Y = 69766.796875,
                X = 17403.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [222] = {
            [1] = 66465,
            [2] = 609,
            [3] = {
                Y = 67701.796875,
                X = 15219.7001953125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [223] = {
            [1] = 66466,
            [2] = 609,
            [3] = {
                Y = 66380.1015625,
                X = 13206.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [224] = {
            [1] = 66467,
            [2] = 609,
            [3] = {
                Y = 49390.6015625,
                X = 35952.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [225] = {
            [1] = 66468,
            [2] = 609,
            [3] = {
                Y = 45474,
                X = 35793.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [226] = {
            [1] = 66469,
            [2] = 609,
            [3] = {
                Y = 46052.6015625,
                X = 31910.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [227] = {
            [1] = 66470,
            [2] = 609,
            [3] = {
                Y = 42019.8984375,
                X = 33762.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [228] = {
            [1] = 66471,
            [2] = 609,
            [3] = {
                Y = 40883.6015625,
                X = 35144.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [229] = {
            [1] = 66472,
            [2] = 609,
            [3] = {
                Y = 41107.1015625,
                X = 30817,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [230] = {
            [1] = 66473,
            [2] = 609,
            [3] = {
                Y = 43352.1015625,
                X = 29080.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [231] = {
            [1] = 66474,
            [2] = 609,
            [3] = {
                Y = 46282.80078125,
                X = 27791.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [232] = {
            [1] = 66475,
            [2] = 609,
            [3] = {
                Y = 38451.19921875,
                X = 21092.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [233] = {
            [1] = 66476,
            [2] = 609,
            [3] = {
                Y = 42840.69921875,
                X = 18373.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [234] = {
            [1] = 66477,
            [2] = 609,
            [3] = {
                Y = 42267.6015625,
                X = 16803.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [235] = {
            [1] = 66478,
            [2] = 609,
            [3] = {
                Y = 42340.30078125,
                X = 13359.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [236] = {
            [1] = 66479,
            [2] = 609,
            [3] = {
                Y = 40171.30078125,
                X = 9455.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [237] = {
            [1] = 66480,
            [2] = 609,
            [3] = {
                Y = 42416.3984375,
                X = 6996.60205078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [238] = {
            [1] = 66481,
            [2] = 609,
            [3] = {
                Y = 44508.8984375,
                X = 6095.10205078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [239] = {
            [1] = 66482,
            [2] = 609,
            [3] = {
                Y = 44918.80078125,
                X = 3310.70288085938,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [240] = {
            [1] = 66483,
            [2] = 609,
            [3] = {
                Y = 44781.3984375,
                X = 1539.10205078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [241] = {
            [1] = 66484,
            [2] = 609,
            [3] = {
                Y = 42444.69921875,
                X = 971.703125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [242] = {
            [1] = 66486,
            [2] = 609,
            [3] = {
                Y = 50651.3984375,
                X = 7553.796875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [243] = {
            [1] = 66487,
            [2] = 609,
            [3] = {
                Y = 3578.79711914063,
                X = 27304.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [244] = {
            [1] = 66488,
            [2] = 609,
            [3] = {
                Y = 2459.89794921875,
                X = 25592.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [245] = {
            [1] = 66489,
            [2] = 609,
            [3] = {
                Y = 3282.70288085938,
                X = 23626.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [246] = {
            [1] = 66490,
            [2] = 609,
            [3] = {
                Y = 4198.703125,
                X = 21649.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [247] = {
            [1] = 66491,
            [2] = 609,
            [3] = {
                Y = 5250.703125,
                X = 20520.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [248] = {
            [1] = 66492,
            [2] = 609,
            [3] = {
                Y = 3785.10205078125,
                X = 27318.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [249] = {
            [1] = 66493,
            [2] = 609,
            [3] = {
                Y = 70097.203125,
                X = 36186.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [250] = {
            [1] = 66494,
            [2] = 609,
            [3] = {
                Y = 71599.5,
                X = 30448.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [251] = {
            [1] = 66495,
            [2] = 609,
            [3] = {
                Y = 64924,
                X = 33026.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [252] = {
            [1] = 66496,
            [2] = 609,
            [3] = {
                Y = 6023.60205078125,
                X = 27940.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [253] = {
            [1] = 66497,
            [2] = 609,
            [3] = {
                Y = 67745.5,
                X = 27406.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [254] = {
            [1] = 66498,
            [2] = 609,
            [3] = {
                Y = 7422.5,
                X = 28465.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [255] = {
            [1] = 66499,
            [2] = 609,
            [3] = {
                Y = 6697.5,
                X = 22925.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [256] = {
            [1] = 66500,
            [2] = 609,
            [3] = {
                Y = 8543.1015625,
                X = 23767.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [257] = {
            [1] = 66501,
            [2] = 609,
            [3] = {
                Y = 7630.60205078125,
                X = 28887,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [258] = {
            [1] = 66502,
            [2] = 609,
            [3] = {
                Y = 8433.203125,
                X = 30381.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [259] = {
            [1] = 66503,
            [2] = 609,
            [3] = {
                Y = 6989.10205078125,
                X = 31374.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [260] = {
            [1] = 66504,
            [2] = 609,
            [3] = {
                Y = 67336.296875,
                X = 19598.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [261] = {
            [1] = 66505,
            [2] = 609,
            [3] = {
                Y = 6835.5,
                X = 32382.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [262] = {
            [1] = 66506,
            [2] = 609,
            [3] = {
                Y = 9215.796875,
                X = 33881.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [263] = {
            [1] = 66507,
            [2] = 609,
            [3] = {
                Y = 10064.5,
                X = 32367,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [264] = {
            [1] = 66508,
            [2] = 609,
            [3] = {
                Y = 10190.900390625,
                X = 31042.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [265] = {
            [1] = 66509,
            [2] = 609,
            [3] = {
                Y = 12567.5,
                X = 30410.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [266] = {
            [1] = 66510,
            [2] = 609,
            [3] = {
                Y = 14197.7998046875,
                X = 31203.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [267] = {
            [1] = 66511,
            [2] = 609,
            [3] = {
                Y = 15544.5,
                X = 33209.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [268] = {
            [1] = 66512,
            [2] = 609,
            [3] = {
                Y = 15951.2001953125,
                X = 34148.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [269] = {
            [1] = 66513,
            [2] = 609,
            [3] = {
                Y = 18330.099609375,
                X = 34072.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [270] = {
            [1] = 66514,
            [2] = 609,
            [3] = {
                Y = 3578.79711914063,
                X = 49595.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [271] = {
            [1] = 66515,
            [2] = 609,
            [3] = {
                Y = 2459.89794921875,
                X = 51307.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [272] = {
            [1] = 66516,
            [2] = 609,
            [3] = {
                Y = 3282.70288085938,
                X = 53273.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [273] = {
            [1] = 66517,
            [2] = 609,
            [3] = {
                Y = 63171.8984375,
                X = 17701.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [274] = {
            [1] = 66518,
            [2] = 609,
            [3] = {
                Y = 61485.30078125,
                X = 13575.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [275] = {
            [1] = 66520,
            [2] = 609,
            [3] = {
                Y = 55771.5,
                X = 14408.7998046875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [276] = {
            [1] = 66521,
            [2] = 609,
            [3] = {
                Y = 52333.19921875,
                X = 7194.10205078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [277] = {
            [1] = 66522,
            [2] = 609,
            [3] = {
                Y = 4198.703125,
                X = 55250.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [278] = {
            [1] = 66523,
            [2] = 609,
            [3] = {
                Y = 5250.703125,
                X = 56379.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [279] = {
            [1] = 66524,
            [2] = 609,
            [3] = {
                Y = 49950.3984375,
                X = 5775.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [280] = {
            [1] = 66525,
            [2] = 609,
            [3] = {
                Y = 3785.10205078125,
                X = 49581.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [281] = {
            [1] = 66526,
            [2] = 609,
            [3] = {
                Y = 6023.60205078125,
                X = 48959.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [282] = {
            [1] = 66527,
            [2] = 609,
            [3] = {
                Y = 46544.80078125,
                X = 7932.60205078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [283] = {
            [1] = 66528,
            [2] = 609,
            [3] = {
                Y = 46702.1015625,
                X = 20712.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [284] = {
            [1] = 66529,
            [2] = 609,
            [3] = {
                Y = 7422.5,
                X = 48434.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [285] = {
            [1] = 66530,
            [2] = 609,
            [3] = {
                Y = 6697.5,
                X = 53974.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [286] = {
            [1] = 66531,
            [2] = 609,
            [3] = {
                Y = 8543.1015625,
                X = 53132.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [287] = {
            [1] = 66532,
            [2] = 609,
            [3] = {
                Y = 7630.60205078125,
                X = 48013,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [288] = {
            [1] = 66533,
            [2] = 609,
            [3] = {
                Y = 8433.203125,
                X = 46518.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [289] = {
            [1] = 66534,
            [2] = 609,
            [3] = {
                Y = 44024.69921875,
                X = 22207.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [290] = {
            [1] = 66535,
            [2] = 609,
            [3] = {
                Y = 6989.10205078125,
                X = 45525.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [291] = {
            [1] = 66536,
            [2] = 609,
            [3] = {
                Y = 46739.6015625,
                X = 24370.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [292] = {
            [1] = 66537,
            [2] = 609,
            [3] = {
                Y = 6835.5,
                X = 44517.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [293] = {
            [1] = 66538,
            [2] = 609,
            [3] = {
                Y = 9215.796875,
                X = 43018.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [294] = {
            [1] = 66539,
            [2] = 609,
            [3] = {
                Y = 10064.5,
                X = 44533,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [295] = {
            [1] = 66540,
            [2] = 609,
            [3] = {
                Y = 51851.6015625,
                X = 28752.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [296] = {
            [1] = 66541,
            [2] = 609,
            [3] = {
                Y = 10190.900390625,
                X = 45857.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [297] = {
            [1] = 66542,
            [2] = 609,
            [3] = {
                Y = 12567.5,
                X = 46489.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [298] = {
            [1] = 66543,
            [2] = 609,
            [3] = {
                Y = 52924.69921875,
                X = 30808.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [299] = {
            [1] = 66544,
            [2] = 609,
            [3] = {
                Y = 14197.7998046875,
                X = 45696.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [300] = {
            [1] = 66545,
            [2] = 609,
            [3] = {
                Y = 50206.80078125,
                X = 31154.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [301] = {
            [1] = 66546,
            [2] = 609,
            [3] = {
                Y = 15544.5,
                X = 43690.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [302] = {
            [1] = 66547,
            [2] = 609,
            [3] = {
                Y = 48816.1015625,
                X = 29056.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [303] = {
            [1] = 66548,
            [2] = 609,
            [3] = {
                Y = 52649.5,
                X = 32701.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [304] = {
            [1] = 66549,
            [2] = 609,
            [3] = {
                Y = 15951.2001953125,
                X = 42751.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [305] = {
            [1] = 66550,
            [2] = 609,
            [3] = {
                Y = 73383.203125,
                X = 38267.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [306] = {
            [1] = 66551,
            [2] = 609,
            [3] = {
                Y = 18330.099609375,
                X = 42827.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [307] = {
            [1] = 66552,
            [2] = 609,
            [3] = {
                Y = 62769.19921875,
                X = 35881.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [308] = {
            [1] = 66553,
            [2] = 609,
            [3] = {
                Y = 19610.5,
                X = 41218.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [309] = {
            [1] = 66554,
            [2] = 609,
            [3] = {
                Y = 60593.19921875,
                X = 30308.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [310] = {
            [1] = 66555,
            [2] = 609,
            [3] = {
                Y = 60630.19921875,
                X = 26012.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [311] = {
            [1] = 66556,
            [2] = 609,
            [3] = {
                Y = 57034.6015625,
                X = 28768.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [312] = {
            [1] = 66557,
            [2] = 609,
            [3] = {
                Y = 56606.6015625,
                X = 25271.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [313] = {
            [1] = 66558,
            [2] = 609,
            [3] = {
                Y = 53916.5,
                X = 20049.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [314] = {
            [1] = 66559,
            [2] = 609,
            [3] = {
                Y = 52063.80078125,
                X = 17739.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [315] = {
            [1] = 66560,
            [2] = 609,
            [3] = {
                Y = 53204.6015625,
                X = 15001.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [316] = {
            [1] = 66561,
            [2] = 609,
            [3] = {
                Y = 61435.30078125,
                X = 9500.796875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [317] = {
            [1] = 66562,
            [2] = 609,
            [3] = {
                Y = 56231.69921875,
                X = 6228.10205078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [318] = {
            [1] = 66563,
            [2] = 609,
            [3] = {
                Y = 53569.6015625,
                X = 4623.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [319] = {
            [1] = 66564,
            [2] = 609,
            [3] = {
                Y = 41327.3984375,
                X = 24193.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [320] = {
            [1] = 66565,
            [2] = 609,
            [3] = {
                Y = 48347.6015625,
                X = 12957.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [321] = {
            [1] = 66566,
            [2] = 609,
            [3] = {
                Y = 54906.8984375,
                X = 36110.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [322] = {
            [1] = 66658,
            [2] = 609,
            [3] = {
                Y = 20714.5,
                X = 38603.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [323] = {
            [1] = 66659,
            [2] = 609,
            [3] = {
                Y = 21238.69921875,
                X = 45364.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [324] = {
            [1] = 66660,
            [2] = 609,
            [3] = {
                Y = 22991.5,
                X = 43930.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [325] = {
            [1] = 66661,
            [2] = 609,
            [3] = {
                Y = 23837.69921875,
                X = 43035.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [326] = {
            [1] = 66662,
            [2] = 609,
            [3] = {
                Y = 22091.80078125,
                X = 46878.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [327] = {
            [1] = 66663,
            [2] = 609,
            [3] = {
                Y = 22577.69921875,
                X = 49061.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [328] = {
            [1] = 66664,
            [2] = 609,
            [3] = {
                Y = 23679.599609375,
                X = 49583.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [329] = {
            [1] = 66665,
            [2] = 609,
            [3] = {
                Y = 25469.599609375,
                X = 50545.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [330] = {
            [1] = 66666,
            [2] = 609,
            [3] = {
                Y = 25579,
                X = 52414.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [331] = {
            [1] = 66667,
            [2] = 609,
            [3] = {
                Y = 26585.80078125,
                X = 51146.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [332] = {
            [1] = 66668,
            [2] = 609,
            [3] = {
                Y = 24631,
                X = 53726.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [333] = {
            [1] = 66669,
            [2] = 609,
            [3] = {
                Y = 22261.099609375,
                X = 54658.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [334] = {
            [1] = 66670,
            [2] = 609,
            [3] = {
                Y = 20483.900390625,
                X = 54918.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [335] = {
            [1] = 66671,
            [2] = 609,
            [3] = {
                Y = 18397.80078125,
                X = 55403,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [336] = {
            [1] = 66672,
            [2] = 609,
            [3] = {
                Y = 14728.099609375,
                X = 55462.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [337] = {
            [1] = 66673,
            [2] = 609,
            [3] = {
                Y = 14042.7001953125,
                X = 55617.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [338] = {
            [1] = 66674,
            [2] = 609,
            [3] = {
                Y = 13737.599609375,
                X = 54638.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [339] = {
            [1] = 66675,
            [2] = 609,
            [3] = {
                Y = 12076,
                X = 53720.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [340] = {
            [1] = 66676,
            [2] = 609,
            [3] = {
                Y = 9887.3984375,
                X = 52695.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [341] = {
            [1] = 66677,
            [2] = 609,
            [3] = {
                Y = 7094.703125,
                X = 53074.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [342] = {
            [1] = 66678,
            [2] = 609,
            [3] = {
                Y = 5293.296875,
                X = 54290.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [343] = {
            [1] = 66679,
            [2] = 609,
            [3] = {
                Y = 26620.900390625,
                X = 55799.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [344] = {
            [1] = 66680,
            [2] = 609,
            [3] = {
                Y = 26942.5,
                X = 57391,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [345] = {
            [1] = 66681,
            [2] = 609,
            [3] = {
                Y = 29081.099609375,
                X = 60686.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [346] = {
            [1] = 66682,
            [2] = 609,
            [3] = {
                Y = 26580.80078125,
                X = 61033.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [347] = {
            [1] = 66683,
            [2] = 609,
            [3] = {
                Y = 25138.900390625,
                X = 62833.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [348] = {
            [1] = 66684,
            [2] = 609,
            [3] = {
                Y = 23900,
                X = 64814.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [349] = {
            [1] = 66685,
            [2] = 609,
            [3] = {
                Y = 21626.900390625,
                X = 65089.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [350] = {
            [1] = 66686,
            [2] = 609,
            [3] = {
                Y = 19687.5,
                X = 66096.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [351] = {
            [1] = 66687,
            [2] = 609,
            [3] = {
                Y = 17179.400390625,
                X = 69491.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [352] = {
            [1] = 66688,
            [2] = 609,
            [3] = {
                Y = 24616.69921875,
                X = 65947.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [353] = {
            [1] = 66689,
            [2] = 609,
            [3] = {
                Y = 25344.80078125,
                X = 67300.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [354] = {
            [1] = 66690,
            [2] = 609,
            [3] = {
                Y = 26274.30078125,
                X = 67825,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [355] = {
            [1] = 66691,
            [2] = 609,
            [3] = {
                Y = 27008,
                X = 68772.796875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [356] = {
            [1] = 66692,
            [2] = 609,
            [3] = {
                Y = 29421.900390625,
                X = 67175.796875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [357] = {
            [1] = 66693,
            [2] = 609,
            [3] = {
                Y = 31446.099609375,
                X = 65962,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [358] = {
            [1] = 66694,
            [2] = 609,
            [3] = {
                Y = 33910.8984375,
                X = 65711.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [359] = {
            [1] = 66695,
            [2] = 609,
            [3] = {
                Y = 35897.1015625,
                X = 65610.203125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [360] = {
            [1] = 66696,
            [2] = 609,
            [3] = {
                Y = 37695.30078125,
                X = 65508.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [361] = {
            [1] = 66697,
            [2] = 609,
            [3] = {
                Y = 19610.5,
                X = 35681.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [362] = {
            [1] = 66698,
            [2] = 609,
            [3] = {
                Y = 24485.400390625,
                X = 40600.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [363] = {
            [1] = 66699,
            [2] = 609,
            [3] = {
                Y = 25562.19921875,
                X = 39033.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [364] = {
            [1] = 66700,
            [2] = 609,
            [3] = {
                Y = 28595.099609375,
                X = 38534,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [365] = {
            [1] = 66701,
            [2] = 609,
            [3] = {
                Y = 31495,
                X = 38769.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [366] = {
            [1] = 66702,
            [2] = 609,
            [3] = {
                Y = 33866.19921875,
                X = 38722.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [367] = {
            [1] = 66703,
            [2] = 609,
            [3] = {
                Y = 36033.80078125,
                X = 38759.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [368] = {
            [1] = 66704,
            [2] = 609,
            [3] = {
                Y = 37954.19921875,
                X = 38987,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [369] = {
            [1] = 66705,
            [2] = 609,
            [3] = {
                Y = 38203.6015625,
                X = 40556.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [370] = {
            [1] = 66706,
            [2] = 609,
            [3] = {
                Y = 29005.80078125,
                X = 49960.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [371] = {
            [1] = 66707,
            [2] = 609,
            [3] = {
                Y = 30904.69921875,
                X = 50764.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [372] = {
            [1] = 66708,
            [2] = 609,
            [3] = {
                Y = 32927.80078125,
                X = 50868,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [373] = {
            [1] = 66709,
            [2] = 609,
            [3] = {
                Y = 34486.5,
                X = 49450,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [374] = {
            [1] = 66710,
            [2] = 609,
            [3] = {
                Y = 36710.30078125,
                X = 49393.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [375] = {
            [1] = 66711,
            [2] = 609,
            [3] = {
                Y = 20714.5,
                X = 38296.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [376] = {
            [1] = 66712,
            [2] = 609,
            [3] = {
                Y = 21238.69921875,
                X = 31535.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [377] = {
            [1] = 66713,
            [2] = 609,
            [3] = {
                Y = 22991.5,
                X = 32969.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [378] = {
            [1] = 66714,
            [2] = 609,
            [3] = {
                Y = 23837.69921875,
                X = 33864.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [379] = {
            [1] = 66715,
            [2] = 609,
            [3] = {
                Y = 22091.80078125,
                X = 30021.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [380] = {
            [1] = 66716,
            [2] = 609,
            [3] = {
                Y = 22577.69921875,
                X = 27838.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [381] = {
            [1] = 66717,
            [2] = 609,
            [3] = {
                Y = 934.296875,
                X = 44337.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [382] = {
            [1] = 66718,
            [2] = 609,
            [3] = {
                Y = 1998.5,
                X = 47287.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [383] = {
            [1] = 66719,
            [2] = 609,
            [3] = {
                Y = 1168.39794921875,
                X = 42011.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [384] = {
            [1] = 66720,
            [2] = 609,
            [3] = {
                Y = 12824,
                X = 52322.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [385] = {
            [1] = 66721,
            [2] = 609,
            [3] = {
                Y = 7133.203125,
                X = 59496.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [386] = {
            [1] = 66722,
            [2] = 609,
            [3] = {
                Y = 9198.203125,
                X = 61680.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [387] = {
            [1] = 66723,
            [2] = 609,
            [3] = {
                Y = 10519.900390625,
                X = 63693.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [388] = {
            [1] = 66724,
            [2] = 609,
            [3] = {
                Y = 27509.400390625,
                X = 40947.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [389] = {
            [1] = 66725,
            [2] = 609,
            [3] = {
                Y = 31426,
                X = 41106.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [390] = {
            [1] = 66726,
            [2] = 609,
            [3] = {
                Y = 30847.400390625,
                X = 44989.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [391] = {
            [1] = 66727,
            [2] = 609,
            [3] = {
                Y = 34880.1015625,
                X = 43137.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [392] = {
            [1] = 66728,
            [2] = 609,
            [3] = {
                Y = 36016.3984375,
                X = 41755.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [393] = {
            [1] = 66729,
            [2] = 609,
            [3] = {
                Y = 35792.8984375,
                X = 46083,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [394] = {
            [1] = 66730,
            [2] = 609,
            [3] = {
                Y = 33547.8984375,
                X = 47819.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [395] = {
            [1] = 66731,
            [2] = 609,
            [3] = {
                Y = 30617.19921875,
                X = 49108.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [396] = {
            [1] = 66732,
            [2] = 609,
            [3] = {
                Y = 23679.599609375,
                X = 27316.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [397] = {
            [1] = 66733,
            [2] = 609,
            [3] = {
                Y = 25469.599609375,
                X = 26354.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [398] = {
            [1] = 66734,
            [2] = 609,
            [3] = {
                Y = 38448.80078125,
                X = 55807.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [399] = {
            [1] = 66735,
            [2] = 609,
            [3] = {
                Y = 34059.30078125,
                X = 58526.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [400] = {
            [1] = 66736,
            [2] = 609,
            [3] = {
                Y = 34632.3984375,
                X = 60096.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [401] = {
            [1] = 66737,
            [2] = 609,
            [3] = {
                Y = 34559.69921875,
                X = 63540.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [402] = {
            [1] = 66738,
            [2] = 609,
            [3] = {
                Y = 25579,
                X = 24485.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [403] = {
            [1] = 66739,
            [2] = 609,
            [3] = {
                Y = 36728.69921875,
                X = 67444.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [404] = {
            [1] = 66740,
            [2] = 609,
            [3] = {
                Y = 34483.6015625,
                X = 69903.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [405] = {
            [1] = 66741,
            [2] = 609,
            [3] = {
                Y = 32391.099609375,
                X = 70804.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [406] = {
            [1] = 66743,
            [2] = 609,
            [3] = {
                Y = 32118.599609375,
                X = 75360.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [407] = {
            [1] = 66744,
            [2] = 609,
            [3] = {
                Y = 34455.30078125,
                X = 75928.296875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [408] = {
            [1] = 66745,
            [2] = 609,
            [3] = {
                Y = 26585.80078125,
                X = 25753.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [409] = {
            [1] = 66746,
            [2] = 609,
            [3] = {
                Y = 27403.599609375,
                X = 74626.203125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [410] = {
            [1] = 66747,
            [2] = 609,
            [3] = {
                Y = 26248.599609375,
                X = 69346.203125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [411] = {
            [1] = 66748,
            [2] = 609,
            [3] = {
                Y = 6802.796875,
                X = 40713.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [412] = {
            [1] = 66749,
            [2] = 609,
            [3] = {
                Y = 5300.5,
                X = 46451.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [413] = {
            [1] = 66750,
            [2] = 609,
            [3] = {
                Y = 11976,
                X = 43873.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [414] = {
            [1] = 66751,
            [2] = 609,
            [3] = {
                Y = 9154.5,
                X = 49493.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [415] = {
            [1] = 66752,
            [2] = 609,
            [3] = {
                Y = 9563.703125,
                X = 57301.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [416] = {
            [1] = 66753,
            [2] = 609,
            [3] = {
                Y = 13728.099609375,
                X = 59198.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [417] = {
            [1] = 66754,
            [2] = 609,
            [3] = {
                Y = 15414.7001953125,
                X = 63324.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [418] = {
            [1] = 66756,
            [2] = 609,
            [3] = {
                Y = 21128.5,
                X = 62491.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [419] = {
            [1] = 66757,
            [2] = 609,
            [3] = {
                Y = 24566.80078125,
                X = 69705.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [420] = {
            [1] = 66758,
            [2] = 609,
            [3] = {
                Y = 26949.599609375,
                X = 71124.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [421] = {
            [1] = 66759,
            [2] = 609,
            [3] = {
                Y = 30355.19921875,
                X = 68967.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [422] = {
            [1] = 66760,
            [2] = 609,
            [3] = {
                Y = 30197.900390625,
                X = 56187.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [423] = {
            [1] = 66761,
            [2] = 609,
            [3] = {
                Y = 32875.30078125,
                X = 54692.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [424] = {
            [1] = 66762,
            [2] = 609,
            [3] = {
                Y = 30160.400390625,
                X = 52529.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [425] = {
            [1] = 66763,
            [2] = 609,
            [3] = {
                Y = 25048.400390625,
                X = 48147.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [426] = {
            [1] = 66764,
            [2] = 609,
            [3] = {
                Y = 23975.30078125,
                X = 46091.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [427] = {
            [1] = 66765,
            [2] = 609,
            [3] = {
                Y = 26693.19921875,
                X = 45745.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [428] = {
            [1] = 66766,
            [2] = 609,
            [3] = {
                Y = 28083.900390625,
                X = 47843.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [429] = {
            [1] = 66767,
            [2] = 609,
            [3] = {
                Y = 24250.5,
                X = 44198.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [430] = {
            [1] = 66768,
            [2] = 609,
            [3] = {
                Y = 3516.79711914063,
                X = 38632.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [431] = {
            [1] = 66769,
            [2] = 609,
            [3] = {
                Y = 14130.7998046875,
                X = 41018.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [432] = {
            [1] = 66770,
            [2] = 609,
            [3] = {
                Y = 24631,
                X = 23173.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [433] = {
            [1] = 66772,
            [2] = 609,
            [3] = {
                Y = 16306.7998046875,
                X = 46591.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [434] = {
            [1] = 66773,
            [2] = 609,
            [3] = {
                Y = 16269.7998046875,
                X = 50887.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [435] = {
            [1] = 66774,
            [2] = 609,
            [3] = {
                Y = 19865.400390625,
                X = 48131.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [436] = {
            [1] = 66775,
            [2] = 609,
            [3] = {
                Y = 20293.400390625,
                X = 51628.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [437] = {
            [1] = 66776,
            [2] = 609,
            [3] = {
                Y = 22983.5,
                X = 56850.1015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [438] = {
            [1] = 66777,
            [2] = 609,
            [3] = {
                Y = 24836.19921875,
                X = 59160.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [439] = {
            [1] = 66778,
            [2] = 609,
            [3] = {
                Y = 23695.400390625,
                X = 61898.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [440] = {
            [1] = 66779,
            [2] = 609,
            [3] = {
                Y = 15464.7001953125,
                X = 67399.203125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [441] = {
            [1] = 66780,
            [2] = 609,
            [3] = {
                Y = 20668.30078125,
                X = 70671.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [442] = {
            [1] = 66781,
            [2] = 609,
            [3] = {
                Y = 23330.400390625,
                X = 72276.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [443] = {
            [1] = 66782,
            [2] = 609,
            [3] = {
                Y = 35572.6015625,
                X = 52706.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [444] = {
            [1] = 66783,
            [2] = 609,
            [3] = {
                Y = 28552.400390625,
                X = 63942.3984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [445] = {
            [1] = 66784,
            [2] = 609,
            [3] = {
                Y = 21993.099609375,
                X = 40789.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [446] = {
            [1] = 66787,
            [2] = 609,
            [3] = {
                Y = 19843.30078125,
                X = 67636.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [447] = {
            [1] = 66795,
            [2] = 609,
            [3] = {
                Y = 22261.099609375,
                X = 22241.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [448] = {
            [1] = 66796,
            [2] = 609,
            [3] = {
                Y = 20483.900390625,
                X = 21981.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [449] = {
            [1] = 66801,
            [2] = 609,
            [3] = {
                Y = 18397.80078125,
                X = 21497,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [450] = {
            [1] = 66802,
            [2] = 609,
            [3] = {
                Y = 14728.099609375,
                X = 21437.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [451] = {
            [1] = 66803,
            [2] = 609,
            [3] = {
                Y = 14042.7001953125,
                X = 21282.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [452] = {
            [1] = 66809,
            [2] = 609,
            [3] = {
                Y = 13737.599609375,
                X = 22261.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [453] = {
            [1] = 66810,
            [2] = 609,
            [3] = {
                Y = 12076,
                X = 23179.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [454] = {
            [1] = 66825,
            [2] = 609,
            [3] = {
                Y = 9887.3984375,
                X = 24204.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [455] = {
            [1] = 66826,
            [2] = 609,
            [3] = {
                Y = 7094.703125,
                X = 23825.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [456] = {
            [1] = 66835,
            [2] = 609,
            [3] = {
                Y = 5293.296875,
                X = 22609.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [457] = {
            [1] = 66836,
            [2] = 609,
            [3] = {
                Y = 26620.900390625,
                X = 21100.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [458] = {
            [1] = 66839,
            [2] = 609,
            [3] = {
                Y = 26942.5,
                X = 19509,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [459] = {
            [1] = 66840,
            [2] = 609,
            [3] = {
                Y = 29081.099609375,
                X = 16213.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [460] = {
            [1] = 66845,
            [2] = 609,
            [3] = {
                Y = 26580.80078125,
                X = 15866.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [461] = {
            [1] = 66846,
            [2] = 609,
            [3] = {
                Y = 25138.900390625,
                X = 14066.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [462] = {
            [1] = 66890,
            [2] = 609,
            [3] = {
                Y = 23900,
                X = 12085.7998046875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [463] = {
            [1] = 66891,
            [2] = 609,
            [3] = {
                Y = 21626.900390625,
                X = 11810.7998046875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [464] = {
            [1] = 66893,
            [2] = 609,
            [3] = {
                Y = 19687.5,
                X = 10803.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [465] = {
            [1] = 66896,
            [2] = 609,
            [3] = {
                Y = 17179.400390625,
                X = 7408.10205078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [466] = {
            [1] = 66897,
            [2] = 609,
            [3] = {
                Y = 24616.69921875,
                X = 10952.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [467] = {
            [1] = 66898,
            [2] = 609,
            [3] = {
                Y = 25344.80078125,
                X = 9599.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [468] = {
            [1] = 66899,
            [2] = 609,
            [3] = {
                Y = 26274.30078125,
                X = 9075,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [469] = {
            [1] = 66900,
            [2] = 609,
            [3] = {
                Y = 27008,
                X = 8127.203125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [470] = {
            [1] = 66901,
            [2] = 609,
            [3] = {
                Y = 29421.900390625,
                X = 9724.203125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [471] = {
            [1] = 66902,
            [2] = 609,
            [3] = {
                Y = 31446.099609375,
                X = 10938,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [472] = {
            [1] = 66903,
            [2] = 609,
            [3] = {
                Y = 33910.8984375,
                X = 11188.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [473] = {
            [1] = 66905,
            [2] = 609,
            [3] = {
                Y = 35897.1015625,
                X = 11289.7998046875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [474] = {
            [1] = 66906,
            [2] = 609,
            [3] = {
                Y = 37695.30078125,
                X = 11391.7998046875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [475] = {
            [1] = 66907,
            [2] = 609,
            [3] = {
                Y = 24485.400390625,
                X = 36299.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [476] = {
            [1] = 66908,
            [2] = 609,
            [3] = {
                Y = 25562.19921875,
                X = 37866.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [477] = {
            [1] = 66909,
            [2] = 609,
            [3] = {
                Y = 28595.099609375,
                X = 38366,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [478] = {
            [1] = 66910,
            [2] = 609,
            [3] = {
                Y = 31495,
                X = 38130.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [479] = {
            [1] = 66911,
            [2] = 609,
            [3] = {
                Y = 33866.19921875,
                X = 38177.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [480] = {
            [1] = 66912,
            [2] = 609,
            [3] = {
                Y = 36033.80078125,
                X = 38140.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [481] = {
            [1] = 66913,
            [2] = 609,
            [3] = {
                Y = 37954.19921875,
                X = 37913,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [482] = {
            [1] = 66914,
            [2] = 609,
            [3] = {
                Y = 38203.6015625,
                X = 36343.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [483] = {
            [1] = 66915,
            [2] = 609,
            [3] = {
                Y = 29005.80078125,
                X = 26939.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [484] = {
            [1] = 66916,
            [2] = 609,
            [3] = {
                Y = 30904.69921875,
                X = 26135.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [485] = {
            [1] = 66917,
            [2] = 609,
            [3] = {
                Y = 32927.80078125,
                X = 26032,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [486] = {
            [1] = 66918,
            [2] = 609,
            [3] = {
                Y = 34486.5,
                X = 27450,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [487] = {
            [1] = 66919,
            [2] = 609,
            [3] = {
                Y = 36710.30078125,
                X = 27506.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [488] = {
            [1] = 66920,
            [2] = 609,
            [3] = {
                Y = 934.296875,
                X = 32562.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [489] = {
            [1] = 66921,
            [2] = 609,
            [3] = {
                Y = 1998.5,
                X = 29612.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [490] = {
            [1] = 66922,
            [2] = 609,
            [3] = {
                Y = 1168.39794921875,
                X = 34888.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [491] = {
            [1] = 66923,
            [2] = 609,
            [3] = {
                Y = 12824,
                X = 24577.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [492] = {
            [1] = 66924,
            [2] = 609,
            [3] = {
                Y = 7133.203125,
                X = 17403.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [493] = {
            [1] = 66925,
            [2] = 609,
            [3] = {
                Y = 9198.203125,
                X = 15219.7001953125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [494] = {
            [1] = 66926,
            [2] = 609,
            [3] = {
                Y = 10519.900390625,
                X = 13206.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [495] = {
            [1] = 66927,
            [2] = 609,
            [3] = {
                Y = 27509.400390625,
                X = 35952.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [496] = {
            [1] = 66928,
            [2] = 609,
            [3] = {
                Y = 31426,
                X = 35793.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [497] = {
            [1] = 66929,
            [2] = 609,
            [3] = {
                Y = 30847.400390625,
                X = 31910.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [498] = {
            [1] = 66930,
            [2] = 609,
            [3] = {
                Y = 34880.1015625,
                X = 33762.8984375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [499] = {
            [1] = 66931,
            [2] = 609,
            [3] = {
                Y = 36016.3984375,
                X = 35144.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [500] = {
            [1] = 66932,
            [2] = 609,
            [3] = {
                Y = 35792.8984375,
                X = 30817,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [501] = {
            [1] = 66933,
            [2] = 609,
            [3] = {
                Y = 33547.8984375,
                X = 29080.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [502] = {
            [1] = 66934,
            [2] = 609,
            [3] = {
                Y = 30617.19921875,
                X = 27791.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [503] = {
            [1] = 66935,
            [2] = 609,
            [3] = {
                Y = 38448.80078125,
                X = 21092.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [504] = {
            [1] = 66936,
            [2] = 609,
            [3] = {
                Y = 34059.30078125,
                X = 18373.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [505] = {
            [1] = 66937,
            [2] = 609,
            [3] = {
                Y = 34632.3984375,
                X = 16803.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [506] = {
            [1] = 66938,
            [2] = 609,
            [3] = {
                Y = 34559.69921875,
                X = 13359.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [507] = {
            [1] = 66939,
            [2] = 609,
            [3] = {
                Y = 36728.69921875,
                X = 9455.6015625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [508] = {
            [1] = 66940,
            [2] = 609,
            [3] = {
                Y = 34483.6015625,
                X = 6996.60205078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [509] = {
            [1] = 66941,
            [2] = 609,
            [3] = {
                Y = 32391.099609375,
                X = 6095.10205078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [510] = {
            [1] = 66942,
            [2] = 609,
            [3] = {
                Y = 31981.19921875,
                X = 3310.70288085938,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [511] = {
            [1] = 66943,
            [2] = 609,
            [3] = {
                Y = 32118.599609375,
                X = 1539.10205078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [512] = {
            [1] = 66944,
            [2] = 609,
            [3] = {
                Y = 34455.30078125,
                X = 971.703125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [513] = {
            [1] = 66945,
            [2] = 609,
            [3] = {
                Y = 27403.599609375,
                X = 2273.79711914063,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [514] = {
            [1] = 66946,
            [2] = 609,
            [3] = {
                Y = 26248.599609375,
                X = 7553.796875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [515] = {
            [1] = 66948,
            [2] = 609,
            [3] = {
                Y = 5300.5,
                X = 30448.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [516] = {
            [1] = 66949,
            [2] = 609,
            [3] = {
                Y = 11976,
                X = 33026.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [517] = {
            [1] = 66950,
            [2] = 609,
            [3] = {
                Y = 9154.5,
                X = 27406.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [518] = {
            [1] = 66951,
            [2] = 609,
            [3] = {
                Y = 9040.3505859375,
                X = 19207.349609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [519] = {
            [1] = 66952,
            [2] = 609,
            [3] = {
                Y = 13728.099609375,
                X = 17701.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [520] = {
            [1] = 66953,
            [2] = 609,
            [3] = {
                Y = 15414.7001953125,
                X = 13575.400390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [521] = {
            [1] = 66955,
            [2] = 609,
            [3] = {
                Y = 21128.5,
                X = 14408.7998046875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [522] = {
            [1] = 66956,
            [2] = 609,
            [3] = {
                Y = 24566.80078125,
                X = 7194.10205078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [523] = {
            [1] = 66957,
            [2] = 609,
            [3] = {
                Y = 26949.599609375,
                X = 5775.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [524] = {
            [1] = 66958,
            [2] = 609,
            [3] = {
                Y = 30355.19921875,
                X = 7932.60205078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [525] = {
            [1] = 66959,
            [2] = 609,
            [3] = {
                Y = 30197.900390625,
                X = 20712.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [526] = {
            [1] = 66960,
            [2] = 609,
            [3] = {
                Y = 32875.30078125,
                X = 22207.80078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [527] = {
            [1] = 66961,
            [2] = 609,
            [3] = {
                Y = 30160.400390625,
                X = 24370.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [528] = {
            [1] = 66962,
            [2] = 609,
            [3] = {
                Y = 25048.400390625,
                X = 28752.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [529] = {
            [1] = 66963,
            [2] = 609,
            [3] = {
                Y = 23975.30078125,
                X = 30808.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [530] = {
            [1] = 66964,
            [2] = 609,
            [3] = {
                Y = 26693.19921875,
                X = 31154.69921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [531] = {
            [1] = 66965,
            [2] = 609,
            [3] = {
                Y = 28083.900390625,
                X = 29056.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [532] = {
            [1] = 66966,
            [2] = 609,
            [3] = {
                Y = 24250.5,
                X = 32701.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [533] = {
            [1] = 66967,
            [2] = 609,
            [3] = {
                Y = 3516.79711914063,
                X = 38267.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [534] = {
            [1] = 66968,
            [2] = 609,
            [3] = {
                Y = 14130.7998046875,
                X = 35881.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [535] = {
            [1] = 66970,
            [2] = 609,
            [3] = {
                Y = 16306.7998046875,
                X = 30308.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [536] = {
            [1] = 66971,
            [2] = 609,
            [3] = {
                Y = 16269.7998046875,
                X = 26012.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [537] = {
            [1] = 66972,
            [2] = 609,
            [3] = {
                Y = 19865.400390625,
                X = 28768.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [538] = {
            [1] = 66973,
            [2] = 609,
            [3] = {
                Y = 20293.400390625,
                X = 25271.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [539] = {
            [1] = 66974,
            [2] = 609,
            [3] = {
                Y = 22983.5,
                X = 20049.900390625,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [540] = {
            [1] = 66975,
            [2] = 609,
            [3] = {
                Y = 24836.19921875,
                X = 17739.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [541] = {
            [1] = 66976,
            [2] = 609,
            [3] = {
                Y = 23695.400390625,
                X = 15001.099609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [542] = {
            [1] = 66977,
            [2] = 609,
            [3] = {
                Y = 15464.7001953125,
                X = 9500.796875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [543] = {
            [1] = 66978,
            [2] = 609,
            [3] = {
                Y = 20668.30078125,
                X = 6228.10205078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [544] = {
            [1] = 66979,
            [2] = 609,
            [3] = {
                Y = 23330.400390625,
                X = 4623.5,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [545] = {
            [1] = 66980,
            [2] = 609,
            [3] = {
                Y = 35572.6015625,
                X = 24193.19921875,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [546] = {
            [1] = 66981,
            [2] = 609,
            [3] = {
                Y = 28552.400390625,
                X = 12957.599609375,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [547] = {
            [1] = 66982,
            [2] = 609,
            [3] = {
                Y = 21993.099609375,
                X = 36110.30078125,
            },
            [4] = 0,
            [5] = "XS_Ambient",
        },
        [548] = {
            [1] = 67099,
            [2] = 33,
            [3] = {
                Y = 61400,
                X = 59600,
            },
            [4] = 0,
            [5] = "PB_VillageCenter1",
        },
        [549] = {
            [1] = 67100,
            [2] = 167,
            [3] = {
                Y = 57576.01953125,
                X = 63084.23828125,
            },
            [4] = 192.999984741211,
            [5] = "PU_Serf",
        },
        [550] = {
            [1] = 67101,
            [2] = 167,
            [3] = {
                Y = 57333.19921875,
                X = 63070.4609375,
            },
            [4] = 192.999984741211,
            [5] = "PU_Serf",
        },
        [551] = {
            [1] = 67102,
            [2] = 167,
            [3] = {
                Y = 57221.33984375,
                X = 62760.80859375,
            },
            [4] = 192.999984741211,
            [5] = "PU_Serf",
        },
        [552] = {
            [1] = 100611,
            [2] = 607,
            [3] = {
                Y = 59307.6015625,
                X = 60580,
            },
            [4] = 0,
            [5] = "XD_ScriptEntity",
        },
        [553] = {
            [1] = 100612,
            [2] = 607,
            [3] = {
                Y = 70368.296875,
                X = 38025.1015625,
            },
            [4] = 0,
            [5] = "XD_ScriptEntity",
        },
        [554] = {
            [1] = 100613,
            [2] = 607,
            [3] = {
                Y = 59086.1015625,
                X = 14103.2001953125,
            },
            [4] = 0,
            [5] = "XD_ScriptEntity",
        },
        [555] = {
            [1] = 100614,
            [2] = 607,
            [3] = {
                Y = 18297.400390625,
                X = 14220.5,
            },
            [4] = 0,
            [5] = "XD_ScriptEntity",
        },
        [556] = {
            [1] = 100615,
            [2] = 607,
            [3] = {
                Y = 7802,
                X = 38121.8984375,
            },
            [4] = 0,
            [5] = "XD_ScriptEntity",
        },
        [557] = {
            [1] = 100616,
            [2] = 607,
            [3] = {
                Y = 17852.30078125,
                X = 60499.6015625,
            },
            [4] = 0,
            [5] = "XD_ScriptEntity",
        },
    },
    [2] = {
    },
    [3] = {
    },
    [4] = {
    },
    [5] = {
    },
    [6] = {
    },
    [7] = {
    },
    [8] = {
    },
}
