// Pacer de respiração (só visual): o círculo cresce na inspiração e encolhe na expiração.
// Tela inicial: UP/DOWN muda o ritmo, segurar UP muda a proporção inspira/expira, START começa.
// Na sessão: START para. No fim: START volta ao início. BACK sai.
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

const RATES = [65, 60, 55, 50, 45];          // respirações/min × 10 (protocolo de Lehrer: 6,5 a 4,5)
const RATIOS = [0.5, 0.4, 0.33];             // fração do ciclo inspirando
const RATIO_NAMES = ["50/50", "40/60", "33/67"];

enum { IDLE, RUN, DONE }

class PacerApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        var view = new PacerView();
        return [view, new PacerDelegate(view)];
    }
}

class PacerView extends WatchUi.View {
    var state = IDLE;
    var rateIdx = 1;
    var ratioIdx = 1;
    var t0 = 0;
    var elapsed = 0;
    var timer;

    function initialize() {
        View.initialize();
        timer = new Timer.Timer();
    }

    function onStartKey() as Void {
        if (state == IDLE) {
            t0 = System.getTimer();
            elapsed = 0;
            state = RUN;
            timer.start(method(:onTick), 100, true);
        } else if (state == RUN) {
            timer.stop();
            state = DONE;
        } else {
            state = IDLE;
        }
        WatchUi.requestUpdate();
    }

    function changeRate(step) as Void {
        var i = rateIdx + step;
        if (state == IDLE && i >= 0 && i < RATES.size()) {
            rateIdx = i;
            WatchUi.requestUpdate();
        }
    }

    function changeRatio() as Void {
        if (state == IDLE) {
            ratioIdx = (ratioIdx + 1) % RATIOS.size();
            WatchUi.requestUpdate();
        }
    }

    function onTick() as Void {
        elapsed = System.getTimer() - t0;
        WatchUi.requestUpdate();
    }

    function rateText() {
        return RATES[rateIdx] / 10 + "," + RATES[rateIdx] % 10 + "/min";
    }

    function clock() {
        var s = elapsed / 1000;
        return s / 60 + ":" + (s % 60).format("%02d");
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if (state != RUN) {
            var lines = state == IDLE
                ? ["Pacer", rateText(), RATIO_NAMES[ratioIdx] + " inspira/expira", "UP/DOWN: ritmo", "segure UP: proporcao", "START: iniciar"]
                : ["FIM", clock(), rateText() + "  " + RATIO_NAMES[ratioIdx], "START: nova"];
            var fh = dc.getFontHeight(Graphics.FONT_TINY);
            var y = (h - fh * lines.size()) / 2;
            for (var i = 0; i < lines.size(); i++) {
                dc.drawText(w / 2, y + i * fh, Graphics.FONT_TINY, lines[i], Graphics.TEXT_JUSTIFY_CENTER);
            }
            return;
        }

        var per = 600000 / RATES[rateIdx];   // ms por respiração
        var ratio = RATIOS[ratioIdx];
        var x = (elapsed % per).toFloat() / per;
        var inhale = x < ratio;
        var level = inhale ? x / ratio : 1 - (x - ratio) / (1 - ratio);
        var ease = (1 - Math.cos(Math.PI * level)) / 2;
        var rMin = w * 0.12;
        var rMax = w * 0.36;
        var left = Math.ceil((inhale ? ratio - x : 1 - x) * per / 1000).toNumber();

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(w / 2, h / 2, rMax);
        dc.setColor(inhale ? 0x3388FF : 0x22BBAA, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(w / 2, h / 2, rMin + (rMax - rMin) * ease);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h / 2, Graphics.FONT_MEDIUM, (inhale ? "Inspire " : "Expire ") + left,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(w / 2, h * 0.06, Graphics.FONT_TINY, clock(), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w / 2, h * 0.84, Graphics.FONT_TINY, rateText() + "  " + RATIO_NAMES[ratioIdx], Graphics.TEXT_JUSTIFY_CENTER);
    }
}

// Só botões físicos (o toque na tela não para a sessão por acidente).
class PacerDelegate extends WatchUi.BehaviorDelegate {
    var view;

    function initialize(v) {
        BehaviorDelegate.initialize();
        view = v;
    }

    function onKey(evt) {
        var key = evt.getKey();
        if (key == WatchUi.KEY_ENTER) {
            view.onStartKey();
            return true;
        }
        if (key == WatchUi.KEY_UP || key == WatchUi.KEY_DOWN) {
            view.changeRate(key == WatchUi.KEY_UP ? -1 : 1);
            return true;
        }
        return false;
    }

    // segurar UP
    function onMenu() {
        view.changeRatio();
        return true;
    }
}
