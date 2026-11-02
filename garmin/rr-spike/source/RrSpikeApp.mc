// Spike: o sensor do pulso do FR965 entrega RR reais por heartBeatIntervals?
// Tela inicial: UP/DOWN escolhe 1 ou 2 min, START grava. Gravando: START para. No fim: START volta ao início.
// Mostra contagem, média, desvio padrão e os últimos 3 RR.
// Log (se existir GARMIN/APPS/LOGS/RRSPIKE.TXT): "start,epoch_s" e linhas "rr,t_ms,valor_ms" e "hr,t_ms,bpm".
// Sem ActivityRecording: a 1ª versão gravava uma atividade e o relógio travou (lista de atividades presa).
import Toybox.Activity;
import Toybox.Application;
import Toybox.Attention;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Sensor;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;
import Toybox.WatchUi;

enum { IDLE, REC, DONE }

class RrSpikeApp extends Application.AppBase {
    var view;

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        view = new RrSpikeView();
        return [view, new RrSpikeDelegate(view)];
    }

    function onStop(state) {
        if (view != null) {
            view.stop();
        }
    }
}

class RrSpikeView extends WatchUi.View {
    var state = IDLE;
    var durationMs = 60000;
    var rr = [];
    var callbacks = 0;
    var hrNow = 0;
    var t0 = 0;
    var elapsed = 0;
    var timer;

    function initialize() {
        View.initialize();
        timer = new Timer.Timer();
    }

    function onStartKey() as Void {
        if (state == IDLE) {
            start();
        } else if (state == REC) {
            stop();
        } else {
            state = IDLE;
            WatchUi.requestUpdate();
        }
    }

    function toggleDuration() as Void {
        if (state == IDLE) {
            durationMs = durationMs == 60000 ? 120000 : 60000;
            WatchUi.requestUpdate();
        }
    }

    function start() as Void {
        rr = [];
        callbacks = 0;
        elapsed = 0;
        t0 = System.getTimer();
        // Horário absoluto (precisão de 1 s) para alinhar com o CSV da câmera e medir o atraso.
        System.println("start," + Time.now().value());
        Sensor.registerSensorDataListener(method(:onData), {
            :period => 1,
            :heartBeatIntervals => {:enabled => true}
        });
        timer.start(method(:onTick), 1000, true);
        state = REC;
        WatchUi.requestUpdate();
    }

    function stop() as Void {
        if (state != REC) {
            return;
        }
        state = DONE;
        timer.stop();
        Sensor.unregisterSensorDataListener();
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(100, 800)]);
        }
        WatchUi.requestUpdate();
    }

    function onData(data as Sensor.SensorData) as Void {
        callbacks++;
        var hr = data.heartRateData;
        if (state != REC || hr == null || hr.heartBeatIntervals == null) {
            return;
        }
        var now = System.getTimer() - t0;
        var ivs = hr.heartBeatIntervals;
        for (var i = 0; i < ivs.size(); i++) {
            rr.add(ivs[i]);
            System.println("rr," + now + "," + ivs[i]);
        }
    }

    function onTick() as Void {
        elapsed = System.getTimer() - t0;
        var info = Activity.getActivityInfo();
        if (info != null && info.currentHeartRate != null) {
            hrNow = info.currentHeartRate;
            System.println("hr," + elapsed + "," + hrNow);
        }
        if (elapsed >= durationMs) {
            stop();
        }
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var lines;
        if (state == IDLE) {
            lines = [
                "RR Spike",
                durationMs / 60000 + " min",
                "UP/DOWN: duracao",
                "START: gravar"
            ];
        } else {
            var n = rr.size();
            var mean = 0.0;
            var sd = 0.0;
            if (n > 0) {
                for (var i = 0; i < n; i++) {
                    mean += rr[i];
                }
                mean /= n;
                for (var i = 0; i < n; i++) {
                    sd += (rr[i] - mean) * (rr[i] - mean);
                }
                sd = Math.sqrt(sd / n);
            }
            var last = "";
            for (var i = (n > 3 ? n - 3 : 0); i < n; i++) {
                last += rr[i] + " ";
            }
            lines = [
                elapsed / 1000 + " / " + durationMs / 1000 + " s",
                "FC " + hrNow + "   cb " + callbacks,
                "RR n=" + n,
                "media " + mean.format("%.0f") + " ms",
                "dp " + sd.format("%.1f") + " ms",
                last,
                state == REC ? "START: parar" : "FIM  START: nova"
            ];
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var fh = dc.getFontHeight(Graphics.FONT_TINY);
        var y = (dc.getHeight() - fh * lines.size()) / 2;
        for (var i = 0; i < lines.size(); i++) {
            dc.drawText(dc.getWidth() / 2, y + i * fh, Graphics.FONT_TINY, lines[i], Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}

// Só botões físicos (o toque na tela não para a gravação por acidente).
class RrSpikeDelegate extends WatchUi.BehaviorDelegate {
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
            view.toggleDuration();
            return true;
        }
        return false;
    }
}
