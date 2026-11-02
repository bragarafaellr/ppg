// Spike: o sensor do pulso do FR965 entrega RR reais por heartBeatIntervals?
// Grava 1 min (START alterna para 2 min) de RR e FC; mostra contagem, média, desvio padrão e os últimos 3 RR.
// Log (se existir GARMIN/APPS/LOGS/RRSPIKE.TXT): "start,epoch_s" e linhas "rr,t_ms,valor_ms" e "hr,t_ms,bpm".
import Toybox.Activity;
import Toybox.ActivityRecording;
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
            view.finish();
        }
    }
}

class RrSpikeView extends WatchUi.View {
    var rr = [];
    var callbacks = 0;
    var hrNow = 0;
    var t0;
    var elapsed = 0;
    var done = false;
    var durationMs = 60000;
    var session;
    var timer;

    function initialize() {
        View.initialize();
        t0 = System.getTimer();
        // Horário absoluto (precisão de 1 s) para alinhar com o CSV da câmera e medir o atraso.
        System.println("start," + Time.now().value());
        Sensor.registerSensorDataListener(method(:onData), {
            :period => 1,
            :heartBeatIntervals => {:enabled => true}
        });
        // Sessão gravando, como seria dentro de uma atividade (e o FIT fica para comparar a FC).
        session = ActivityRecording.createSession({:name => "RR Spike", :sport => Activity.SPORT_GENERIC});
        session.start();
        timer = new Timer.Timer();
        timer.start(method(:onTick), 1000, true);
    }

    function onData(data as Sensor.SensorData) as Void {
        callbacks++;
        var hr = data.heartRateData;
        if (done || hr == null || hr.heartBeatIntervals == null) {
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
            finish();
        }
        WatchUi.requestUpdate();
    }

    function toggleDuration() as Void {
        if (!done) {
            durationMs = durationMs == 60000 ? 120000 : 60000;
            WatchUi.requestUpdate();
        }
    }

    function finish() as Void {
        if (done) {
            return;
        }
        done = true;
        timer.stop();
        Sensor.unregisterSensorDataListener();
        if (session.isRecording()) {
            session.stop();
            session.save();
        }
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(100, 800)]);
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
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
        var lines = [
            (done ? "FIM  " : "") + elapsed / 1000 + " / " + durationMs / 1000 + " s",
            "FC " + hrNow + "   cb " + callbacks,
            "RR n=" + n,
            "media " + mean.format("%.0f") + " ms",
            "dp " + sd.format("%.1f") + " ms",
            last
        ];

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var fh = dc.getFontHeight(Graphics.FONT_SMALL);
        var y = (dc.getHeight() - fh * lines.size()) / 2;
        for (var i = 0; i < lines.size(); i++) {
            dc.drawText(dc.getWidth() / 2, y + i * fh, Graphics.FONT_SMALL, lines[i], Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}

class RrSpikeDelegate extends WatchUi.BehaviorDelegate {
    var view;

    function initialize(v) {
        BehaviorDelegate.initialize();
        view = v;
    }

    function onSelect() {
        view.toggleDuration();
        return true;
    }
}
