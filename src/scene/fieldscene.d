module scene.fieldscene;

import laziness;
import scene.abstscene;
import widget.btn;
import dungeon;


private Dungeon info_dungeon;

class FieldScene: AbstScene{
    mixin ins;


    private this(){

    }

    override void start(){
        setup;
        super.start;
    }

    private void setup(){
        clear;

        add((g,bounds){
            g.set(Color.BLACK);
            g.fill(bounds);
        });

        add(Bounds.Ratio.BOTTOM, DrawBottom.ins);

        add(Bounds.Ratio.UPPER_LEFT,{
            
            Labels labels = new Labels(Util.font)
                                .setOutsideMargin(2,2,2,2)
                                .add(()=> format!"[%s]"( info_dungeon ))
                                .add(()=> format!"Rank:%s"( info_dungeon.getRank ))
                                .add(()=> format!"AU:%s"( info_dungeon.getAU ))
                                .add(()=> format!"攻略回数:%s"( info_dungeon.clear_num ))
                                .add(()=> format!"財宝入手:%s"( info_dungeon.opened_tresure_num ))
                                .add(()=> format!"EX撃破数:%s"( info_dungeon.killed_ex_num ))
                                ;

            return new Layout()
                    .add((g,bounds){
                        g.set(Color.L_GRAY);
                        g.line(bounds);
                    })
                    .add(new BorderLayout()
                        .add!"top"( (new Label(Util.font, ()=>format!"-%s-"(Area.now))).setDrawPoint!"center" )
                        .add!"center"( new VariableLayout(()=> info_dungeon is null ? ILayout.empty : labels) )
                    );
        }());
        add(Bounds.Ratio.BTN, createBtn);
        add(Bounds.Ratio.MAIN, createMain);
        add(Bounds.Ratio.PLAYER_STATUS_BOXES, DrawPlayerStatusBoxes.ins);
        add(Bounds.Ratio.ENEMY_STATUS_BOXES, DrawEnemyStatusBoxes.ins);
        
        add(Bounds.Ratio.UPPER_RIGHT, DrawUpperRight.ins);
        add(Bounds.Ratio.UNIT_DETAIL, DrawUnitDetail.ins);
    }
}


private ILayout createBtn(){

    FrameLayout l = new FrameLayout;
    l.add({
        auto box = new PackedYLayout( Bounds.BTN_H );
        
        void addBtn(bool delegate() visible_dlgt, string name, void delegate() push, void delegate() cursor_on){

            bool delegate() visible = ()=> visible_dlgt() || Test.appear_all_btn;

            import std.string: tr;
            box.add(
                new Btn(
                     ()=> visible() ? name : name.tr(".","？","cd")
                    ,{
                        if(!visible()){return;}
                        push();
                    },{
                        if(!visible()){return;}
                        cursor_on(); 
                    }
                )
            );
        }

        addBtn(
            ()=> PlayData.tec_btn_visible
            ,"技のセット",{
                import scene.settecscene;
                SetTecScene.ins.start;
                FieldScene.ins.setup();
            },{

            }
        );
        addBtn(
            ()=> PlayData.job_btn_visible
            ,"ジョブ",{
                import scene.jobchangescene;
                JobChangeScene.ins.start;
                FieldScene.ins.setup();
            },{

            }
        );
        addBtn(
            ()=> PlayData.eq_btn_visible
            ,"装備",{
                import scene.eqscene;
                EqScene.ins.start;
                FieldScene.ins.setup();
            },{

            }
        );
        addBtn(
            ()=> PlayData.meisou_btn_visible
            ,"瞑想",{
                import scene.meisouscene;
                MeisouScene.ins.start;
                FieldScene.ins.setup();
            },{

            }
        );
        addBtn(
            ()=> PlayData.item_btn_visible
            ,"アイテム",{
                import scene.itemscene;
                ItemSceneField.ins.start;
                FieldScene.ins.setup();
            },{

            }
        );
        addBtn(
            ()=> Dungeon.はじまりの街.clear_num > 0
            ,"合成",{
                import scene.compositionscene;
                CompositionScene.ins.start;
                FieldScene.ins.setup();
            },{

            }
        );
        addBtn(
            ()=> PlayData.save_btn_visible
            ,"セーブ",{
                import save;
                Save.save();
                import effect: Effect;
                Effect.flipStr( "セーブ完了", Bounds.WINDOW.center.to!float, Color.WHITE, Font.of(25, Font.Style.BOLD) );
            },{

            }
        );

        return box;
    }());

    return l;
}


private ILayout createMain(){
    import dungeon;
    import scene.dungeonscene;
    auto l = new RatioLayout;

    l.add((g,bounds){
        Area.now.draw(g,bounds);
    });

    Dungeon.values
        .filter!(d=> d.getArea == Area.now)
        .filter!(d=> d.isVisible)
        .each!((d){

            l.add(d.btn_bounds,{
                Btn btn = new Btn(d.toString,{
                    fullCare();

                    Dungeon.escape = false;
                    Dungeon.now = d;
                    DungeonScene.ins.start;

                    fullCare();
                },{
                    info_dungeon = d;
                });

                btn.set!"frame"(Color.WHITE);
                btn.set!"frame_on"(Color.WHITE);

                return btn;
            }());
        });
    return l;
}


private void fullCare(){
    import unit;
    foreach(p; Unit.players){
        if(!p.exists){continue;}

        p.dead = false;
        p.hp = p.prm!"MAX_HP".total;
        p.mp = p.prm!"MAX_MP".total;
        p.tp = 0;
    }
}