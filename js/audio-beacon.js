// ===================================================================
// TERRAPULSE - Acoustic Emergency Beacon & Morse Synthesizer
// Web Audio API pure tone generator for off-grid survival acoustic ping
// ===================================================================

class AudioEmergencyBeacon {
  constructor() {
    this.audioCtx = null;
    this.isPlaying = false;
    this.oscillator = null;
    this.gainNode = null;
    this.intervalId = null;
  }

  getAudioContext() {
    if (!this.audioCtx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      this.audioCtx = new AudioContext();
    }
    if (this.audioCtx.state === 'suspended') {
      this.audioCtx.resume();
    }
    return this.audioCtx;
  }

  // Play a brief high-tech UI feedback chirp
  playChirp(freq = 880, duration = 0.08) {
    try {
      const ctx = this.getAudioContext();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(freq * 1.5, ctx.currentTime + duration);

      gain.gain.setValueAtTime(0.08, ctx.currentTime);
      gain.gain.linearRampToValueAtTime(0.001, ctx.currentTime + duration);

      osc.connect(gain);
      gain.connect(ctx.destination);

      osc.start();
      osc.stop(ctx.currentTime + duration);
    } catch (e) {
      console.warn("Audio Context not allowed without user gesture", e);
    }
  }

  // Toggle Continuous High-Decibel Acoustic Distress Siren
  toggleDistressSiren() {
    if (this.isPlaying) {
      this.stopDistressSiren();
      return false;
    } else {
      this.startDistressSiren();
      return true;
    }
  }

  startDistressSiren() {
    const ctx = this.getAudioContext();
    this.isPlaying = true;

    this.oscillator = ctx.createOscillator();
    this.gainNode = ctx.createGain();

    this.oscillator.type = 'sawtooth';
    this.gainNode.gain.setValueAtTime(0.12, ctx.currentTime);

    // LFO frequency modulation (800Hz to 1200Hz alternating alarm)
    let high = false;
    this.oscillator.frequency.setValueAtTime(800, ctx.currentTime);

    this.intervalId = setInterval(() => {
      if (!this.isPlaying) return;
      high = !high;
      const targetFreq = high ? 1200 : 750;
      this.oscillator.frequency.setTargetAtTime(targetFreq, ctx.currentTime, 0.08);

      // Strobe screen visual flash
      const flash = document.getElementById('beaconScreenFlash');
      if (flash) {
        flash.classList.toggle('active', high);
      }
    }, 450);

    this.oscillator.connect(this.gainNode);
    this.gainNode.connect(ctx.destination);
    this.oscillator.start();
  }

  stopDistressSiren() {
    this.isPlaying = false;
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
    if (this.oscillator) {
      try {
        this.oscillator.stop();
        this.oscillator.disconnect();
      } catch (e) {}
      this.oscillator = null;
    }
    const flash = document.getElementById('beaconScreenFlash');
    if (flash) flash.classList.remove('active');
  }

  // Play International Morse SOS: · · · — — — · · ·
  playMorseSOS() {
    const ctx = this.getAudioContext();
    const dot = 0.12; // duration of a dot in seconds
    const dash = dot * 3;
    const freq = 950; // crisp penetrating acoustic pitch

    // SOS pattern: 3 dots, 3 dashes, 3 dots
    const pattern = [
      { dur: dot, sound: true }, { dur: dot, sound: false },
      { dur: dot, sound: true }, { dur: dot, sound: false },
      { dur: dot, sound: true }, { dur: dash, sound: false }, // end of S
      
      { dur: dash, sound: true }, { dur: dot, sound: false },
      { dur: dash, sound: true }, { dur: dot, sound: false },
      { dur: dash, sound: true }, { dur: dash, sound: false }, // end of O

      { dur: dot, sound: true }, { dur: dot, sound: false },
      { dur: dot, sound: true }, { dur: dot, sound: false },
      { dur: dot, sound: true }, { dur: dash * 2, sound: false } // end of S
    ];

    let time = ctx.currentTime + 0.05;

    pattern.forEach(step => {
      if (step.sound) {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(freq, time);
        gain.gain.setValueAtTime(0.15, time);
        gain.gain.setValueAtTime(0.0001, time + step.dur);

        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(time);
        osc.stop(time + step.dur);
      }
      time += step.dur;
    });
  }
}

window.audioBeacon = new AudioEmergencyBeacon();
