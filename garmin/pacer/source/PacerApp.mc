// Pacer de respiração como data field (só visual), para usar dentro da corrida:
// o círculo cresce na inspiração e encolhe na expiração, com os segundos que faltam na fase.
// Anda com o cronômetro da atividade (começa e pausa junto). Data field redesenha 1 vez por segundo.
// Ritmo e proporção são fixos: para mudar, altere as constantes e recompile.
import Toybox.Activity;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

const RATE_X10 = 60;   // respirações/min × 10 (6,0/min)
const INHALE = 0.4;    // fração do ciclo inspirando (40/60)

class PacerApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [new PacerField()];
    }
}

class PacerField extends WatchUi.DataField {
    var timerMs = 0;

    function initialize() {
        DataField.initialize();
    }

    function compute(info as Activity.Info) as Void {
        timerMs = info.timerTime != null ? info.timerTime : 0;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var bg = getBackgroundColor();
        var fg = bg == Graphics.COLOR_BLACK ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
        var big = w > 300 && h > 300;   // campo único (tela cheia)
        var font = big ? Graphics.FONT_MEDIUM : h > 100 ? Graphics.FONT_SMALL : Graphics.FONT_TINY;
        var label = RATE_X10 / 10 + "," + RATE_X10 % 10 + "/min  " + (INHALE * 100).toNumber() + "/" + (100 - INHALE * 100).toNumber();
        dc.setColor(fg, bg);
        dc.clear();

        if (timerMs == 0) {
            dc.drawText(w / 2, h / 2, font, "Pacer", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            if (big) {
                dc.drawText(w / 2, h * 0.6, Graphics.FONT_TINY, label, Graphics.TEXT_JUSTIFY_CENTER);
            }
            return;
        }

        var per = 600000 / RATE_X10;   // ms por respiração
        var x = (timerMs % per).toFloat() / per;
        var inhale = x < INHALE;
        var level = inhale ? x / INHALE : 1 - (x - INHALE) / (1 - INHALE);
        var ease = (1 - Math.cos(Math.PI * level)) / 2;
        var rMax = (w < h ? w : h) * (big ? 0.36 : 0.45);
        var rMin = rMax * 0.33;
        var left = Math.ceil((inhale ? INHALE - x : 1 - x) * per / 1000).toNumber();

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(w / 2, h / 2, rMax);
        dc.setColor(inhale ? 0x3388FF : 0x22BBAA, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(w / 2, h / 2, rMin + (rMax - rMin) * ease);
        dc.setColor(fg, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h / 2, font, (inhale ? "Inspire " : "Expire ") + left,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        if (big) {
            dc.drawText(w / 2, h * 0.84, Graphics.FONT_TINY, label, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}
