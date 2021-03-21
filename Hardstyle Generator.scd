//boot server
s.boot;

//if you want to see what is going on
s.plotTree;

//(mode,fullpath)
//mode: "p" = play in real time, "w" = write to file in non-real-time
//fullpath: full file path, name and all
~function.value("w","/Users/nokkvi/Desktop/this/out.wav");

(//execute here to bypass highlighting
~function = {arg mode, fullpath;
	var tempo, loop,

	rhythm, rhythm_2, rhythm_3, quarter_rhythm, backbeat_rhythm, synth_rhythm,
	length, length_2, length_3, synth_length,
	pitch, pitch_2, pitch_3, synth_pitch,

	coef, coef_2, pan, curve_available, curve, cutoff_start, cutoff_end, lforate, tail, clap_curve,

	reverb_bus, revtime, earlyreflevel, damping, taillevel,

	synthdefs, score, form_function, form, climaxes, score_function,

	available, root_index, misc_index,

	number, placeholder;

tempo = rrand(60,80);
TempoClock.default.tempo = tempo/60;

//a variable to create whole bar(always 4/4 time) loops, in this case 4 bars
loop = 4;

//parameters for intrument 1("pluck"), only 1 bar
length = Array.fill(rrand(4,16),{[0.125,0.25,0.375,0.5].choose});
while({length.sum!=2},{length = Array.fill(rrand(4,16),{[0.125,0.25,0.375,0.5].choose});});
rhythm = Array.fill(length.size,{0});

available = Array.fill(2,{rrand(25,85)});

pitch = Array.fill(length.size,{rrand(available.at(0),available.at(1))});
coef = Array.fill(length.size,{rrand(1,9)/10});

number=0;
(
while({number<length.size},
	  {if(number==0,
		  {},
		  {rhythm.put(number,length.at(Array.series(number,0,1)).sum;)});
	   number=number+1;});
);

//loop amount(in this case 4) of bars for drums("kick","clap")
//quarter note kicks with claps on 2 and 4
root_index = length.collect({arg item, index;
	                               if(item==length.maxItem,
		                              {index;},
		                              {});}).removeEvery([nil]);

quarter_rhythm = Array.series(4*loop,rhythm.at(root_index.at(0)),0.5);
backbeat_rhythm = quarter_rhythm.collect({arg item, index; if(index.even,{},{item});}).removeEvery([nil]);

//4 4/4 bars of held chord instrument("synth")(not adjustable as of now)
synth_pitch = [pitch.at(root_index.at(0))];
while({synth_pitch.at(0)<60},{synth_pitch=[synth_pitch.at(0)+12]});
while({synth_pitch.at(0)>90},{synth_pitch=[synth_pitch.at(0)-12]});

synth_rhythm = [rhythm.at(root_index.at(0))];
synth_length = [8];

//parameters for intrument 2("another pluck"), only 1 bar
pitch_2 = Array.fill(root_index.size,{0});

number=0;
while({number<root_index.size},{if(pitch.at(root_index.at(number))<=55,
	                                 {pitch_2.put(number,(pitch.at(root_index.at(number))+24))},
	                                 {pitch_2.put(number,(pitch.at(root_index.at(number))-24))});
                                  number=number+1;});

rhythm_2 = rhythm.at(root_index);

length_2 = length.at(root_index);

misc_index = length.collect({arg item, index;
	                               if(item==length.minItem,
		                              {index;},
		                              {});}).removeEvery([nil]);

//parameters for intrument 3("crotales"), only 1 bar
length_3 = length.at(misc_index);

rhythm_3 = rhythm.at(misc_index);

pitch_3 = pitch.at(misc_index);

//parameters for instruments 1-3("pluck","another pluck","crotales"), how many repeats(determined by loop variable) per section
length = Array.fill(loop,{length}).flat;
pitch = Array.fill(loop,{pitch}).flat;
coef = Array.fill(loop,{coef}).flat;

placeholder = Array.series(loop,0,2);
number=0;
while({number<loop},{placeholder.put(number,(placeholder.at(number)+rhythm));number=number+1;});
rhythm = placeholder.flat;

length_2 = Array.fill(loop,{length_2}).flat;
pitch_2 = Array.fill(loop,{pitch_2}).flat;
coef_2 = Array.fill(pitch_2.size,{rrand(1,9)/10});

placeholder = Array.series(loop,0,2);
number=0;
while({number<loop},{placeholder.put(number,(placeholder.at(number)+rhythm_2));number=number+1;});
rhythm_2 = placeholder.flat;

length_3 = Array.fill(loop,{length_3}).flat;

placeholder = Array.series(loop,0,2);
number=0;
while({number<loop},{placeholder.put(number,(pitch_3+([-12,12].choose*number)));number=number+1;});
pitch_3 = placeholder.flat;

pitch_3 = pitch_3.collect({arg item; if(item<=12,{item+24},{item});});

pitch_3 = pitch_3.collect({arg item; if(item<=35, {item+[24,36].choose},{if(item>85,{item-[12,24].choose},{item});})});

placeholder = Array.series(loop,0,2);
number=0;
while({number<loop},{placeholder.put(number,(placeholder.at(number)+rhythm_3));number=number+1;});
rhythm_3 = placeholder.flat;

//misc parameters for instruments
pan = Array.fill(rhythm_3.size,{rrand(-0.5,0.5)});

curve_available = Array.fill(2,{rrand(-6,6)});
curve = Array.fill(rhythm_3.size,{rrand(curve_available.at(0),curve_available.at(1))});

//parameters for reverb
revtime = rrand(0.1,5);
earlyreflevel = rrand(0,1);
damping = rrand(0,0.9);
taillevel = rrand(0.3,1);

//7 synthdefs chucked into a CtkProtoNotes for later usage
synthdefs = CtkProtoNotes.new(
	SynthDef("pluck", {arg amp, freq, decay, coef, out;
	var env, snd;
	env = EnvGen.kr(Env.linen(0, decay, 0), doneAction: 2);
	snd = Pluck.ar(
		in: WhiteNoise.ar(amp),
		trig: Impulse.kr(0),
		maxdelaytime: 0.1,
		delaytime: freq.reciprocal,
		decaytime: decay,
		coef: coef);
	Out.ar(out, [snd, snd]);
    }),

	SynthDef("another pluck", {arg amp, freq, decay, coef, out;
	var env, snd;
	env = EnvGen.kr(Env.linen(0, decay, 0), doneAction: 2);
	snd = Pluck.ar(
		in: BrownNoise.ar(amp),
		trig: Impulse.kr(0),
		maxdelaytime: 0.1,
		delaytime: freq.reciprocal,
		decaytime: decay,
		coef: coef);
	Out.ar(out, [snd, snd]);
    }),

	SynthDef("pmCrotales", {
	arg out = 0, freq, tone = 3, att = 0, rel = 2, curve = -6, amp, pan, modLo = 5.25, modHi = 5.5;

	var env, snd, mod;

	env = Env.perc(attackTime: 0, releaseTime: rel, curve: curve).kr(doneAction: 2);

	mod = Rand(modLo, modHi);

	snd = PMOsc.ar(
	    	carfreq: freq,
	    	modfreq: mod * freq,
	    	pmindex: env * tone,
	    	mul: env * amp
	    );

	snd = HPF.ar(snd, freq / 2);

	snd = Mix.ar(snd);

	Out.ar(out, Pan2.ar(snd, pan));
}),

	SynthDef("kick", {
	arg out = 0, amp = 0.1, pan = 0, att = 0.005, rel = 0.29, curve = -4,
	filterHarmonic = 1.5, preamp = 1.25, pulseAmp = 0.5, noiseAmp = 1, sineAmp = 1;

	var env, envp, snd;

	env = Env.new(levels: [0.5, 1, 0.5, 0], times: [att, rel * 0.2, rel * 0.9], curve: [curve, curve/2, curve]).kr(doneAction:2);
	envp = Env.new(levels: [110, 59, 29], times: [att, rel], curve: [curve, curve * 1.25]).kr.midicps;

	snd = LFPulse.ar(freq: envp).range(-1 * pulseAmp, pulseAmp);
	snd = snd + WhiteNoise.ar(mul: noiseAmp);
	snd = LPF.ar(in: snd, freq: envp * filterHarmonic, mul: env);
	snd = snd + SinOsc.ar(freq: envp, phase: 0.5, mul: env * sineAmp);

	snd = Mix.ar(snd) * preamp;
	snd = snd.clip2(1) * amp;
	snd = LeakDC.ar(snd);

	Out.ar(out, Pan2.ar(snd));
}),
	SynthDef("clap", {
	arg out = 0, amp = 0.1, pan = 0, tail, curve;
	var env1, env2, snd, noise1, noise2;

	env1 = Env.new(
		levels: [0, 1, 0, 1, 0, 1, 0, 1, 0],
		times: [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03],
		curve: [0, -3, 0, -3, 0, -3, 0, -4]
	).ar;
	env2 = Env.new(
		levels: [0, 1, 0],
		times: [0.02, tail],
		curve: [0, curve]
	).ar(doneAction: 2);

	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = BPF.ar(noise1, 2000, 3);

	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

	snd = noise1 + noise2;
	snd = snd * 2;
	snd = snd.softclip * amp;
	snd = LeakDC.ar(snd);

	Out.ar(out, Pan2.ar(snd, pan));
}),

	SynthDef("synth", {
	arg out = 0, pan = 0.0, freq = 440,
		amp = 1.0, gate = 1, att = 0,
		rel = 0, sus = 8,
		lforate = 10, lfowidth = 0.5, rq = 0.5, start = 500, end = 15000;

	var lfo, pulse, filter, env;
	lfo = LFTri.kr(lforate * [1, 1.01], Rand(0, 2.0) ! 2);
	pulse = Pulse.ar(freq * [1, 1.01], lfo * lfowidth + 0.5);
		filter = RLPF.ar(pulse, Line.kr(start,end,sus/(tempo/60)), rq);
	env = EnvGen.ar(
			envelope: Env.new([0,1,1,0],[att, sus/(tempo/60), rel]),
		gate: gate,
		doneAction: 2);
	filter = LeakDC.ar(filter);
	Out.ar(out, Pan2.ar(
		in: Mix(filter*amp) * env,
		pos: pan)
	);
}),

    SynthDef(\reverb, {
	arg in,duration,revtime,earlyreflevel,damping,taillevel,amp;
	var sig;
	sig = In.ar(in, 2);
	sig = GVerb.ar(sig, roomsize: 10,
			            revtime: revtime,
			            damping: damping,
			            drylevel:0,
			            earlyreflevel:earlyreflevel,
			            taillevel: taillevel);
	sig = sig*EnvGen.kr(Env([1,1,0],[duration,0]),doneAction:2);
	sig = LeakDC.ar(sig);
		Out.ar([0,1], sig*amp);
    });

);

//a score created to be filled later
score = CtkScore.new;

//a bus
reverb_bus = CtkAudio.new(2);

//a function to create the structure of the music
form_function = {var former, placeholder, big_no_no, data, number;

	data = [];

	number=0;
	while({number<3},
		 {former = Array.fill(3,{0}).put(rrand(0,2),1);
	      big_no_no = former.collect({arg item, index; if(item==1,{index},{})}).removeEvery([nil]);
	      placeholder = former.collect({arg item, index; if(item==0,{index},{})}).removeEvery([nil]).choose;
	      former = [former,former.collect({arg item; item}).put(placeholder,1),[1,1,1],[1,1,1]];
	      form = former;

	      former = Array.fill(3,{0}).put([0,1,2].removeEvery(big_no_no).choose,1);
	      big_no_no = big_no_no++former.collect({arg item, index; if(item==1,{index},{})}).removeEvery([nil]);
	      placeholder = former.collect({arg item, index; if(item==0,{index},{})}).removeEvery([nil]).choose;
	      former = [former,former.collect({arg item; item}).put(placeholder,1),[1,1,1],[1,1,1]];
	      form = form++former;

	      former = Array.fill(3,{0}).put([0,1,2].removeEvery(big_no_no).choose,1);
	      placeholder = former.collect({arg item, index; if(item==0,{index},{})}).removeEvery([nil]).choose;
	      former = [former,former.collect({arg item; item}).put(placeholder,1),[1,1,1],[1,1,1]];
	      form = form++former;

	      form = form.rotate(rrand(-3,0));

	      data = data++form;
			number=number+1;
	});
	form = data
};

form_function.value();

/*
structure of drums and chord instruments("kick","clap","synth") according to form
at this point the system looks for a specific array([1,1,1]) and uses it to decide
where aforementioned instruments should and should not play
*/

climaxes = form.collect({arg item, index; if(item==[1,1,1],{index},{});}).removeEvery([nil]).removeEvery([0])*(loop*2);

quarter_rhythm = climaxes.collect({arg item; item;}).removeEvery([8]).collect({arg item; item+quarter_rhythm}).flat;
backbeat_rhythm = climaxes.collect({arg item; item+backbeat_rhythm}).flat;

synth_pitch = [synth_pitch.at(0),synth_pitch.at(0)+12,synth_pitch.at(0)+24,synth_pitch.at(0)+36];

synth_pitch = Array.fill(rrand(6,form.size),{synth_pitch.choose});

synth_length = Array.fill(synth_pitch.size,{synth_length.at(0)});

placeholder = Array.series(form.size,0,1);
while({placeholder.size>synth_pitch.size},{placeholder = placeholder.removeEvery([placeholder.choose])});
synth_rhythm = (placeholder*8)+synth_rhythm;

//parameters for filter sweeps on chord instrument
cutoff_start = Array.fill(synth_rhythm.size,{rrand(500,12000)});
cutoff_end = Array.fill(synth_rhythm.size,{rrand(500,12000)});

//lforate of "synth"
lforate = Array.fill(synth_rhythm.size,{rrand(10,100)});

//clap sound altering parameters
tail = Array.fill(2,{(rrand(1,10))/10});
tail = Array.fill(backbeat_rhythm.size/2,{tail}).flat;

clap_curve = Array.fill(2,{rrand(-9,0)});
clap_curve = Array.fill(backbeat_rhythm.size/2,{clap_curve}).flat;

/*function intended to fill score
the array contained within the variable form governs when instruments 1-3("pluck","another pluck","crotales") are played
*/
score_function = {var now, onoff,integer, duration;

synthdefs[\reverb].note(0)
	      .in_(reverb_bus)
	      .duration_((length.sum*form.size)+revtime)
	      .revtime_(revtime)
	      .earlyreflevel_(earlyreflevel)
	      .damping_(damping)
	      .taillevel_(taillevel)
	      .amp_(0.4)
	      .addTo(score);

integer=0;
while({integer<form.size},
	  {onoff = form.at(integer);

       if(onoff.at(0)==1,
		           {now = 0;
                    duration = rhythm.size;
                    while({now<duration},
	                      {synthdefs["pluck"].note(rhythm.collect({arg item; item+(integer*8)}).at(now))
			                         .freq_(pitch.at(now).midicps)
			                         .amp_(0.1)
			                         .decay_(length.at(now))
			                         .coef_(coef.at(now))
			                         .out_(reverb_bus)
			                         .addTo(score);
	                       now=now+1;});},
		                 {});

	  if(onoff.at(1)==1,
		          {now = 0;
	               duration = rhythm_2.size;
                   while({now<duration},
	                     {synthdefs["another pluck"].note(rhythm_2.collect({arg item; item+(integer*8)}).at(now))
			                                .freq_(pitch_2.at(now).midicps)
			                                .amp_(0.1)
			                                .decay_(length_2.at(now))
			                                .coef_(coef_2.at(now))
			                                .out_(reverb_bus)
			                                .addTo(score);
	                      now=now+1;});},
		                 {});

	  if(onoff.at(2)==1,
		          {now = 0;
	               duration = rhythm_3.size;
                   while({now<duration},
	                     {synthdefs["pmCrotales"].note(rhythm_3.collect({arg item; item+(integer*8)}).at(now))
			                             .freq_(pitch_3.at(now).midicps)
			                             .amp_(0.1)
			                             .rel_(length_3.at(now))
			                             .pan_(pan.at(now))
			                             .curve_(curve.at(now))
			                             .out_(reverb_bus)
			                             .addTo(score);
	                     now=now+1;});},
		                {});integer=integer+1;});

	now=0;
	duration=quarter_rhythm.size;
	while({now<duration},{synthdefs["kick"].note(quarter_rhythm.at(now))
			                             .amp_(0.2)
			                             .out_(reverb_bus)
			                             .addTo(score);
	                     now=now+1;});

	now=0;
	duration=backbeat_rhythm.size;
	while({now<duration},{synthdefs["clap"].note(backbeat_rhythm.at(now))
			                             .amp_(0.3)
			                             .tail_(tail.at(now))
			                             .curve_(clap_curve.at(now))
			                             .out_(reverb_bus)
			                             .addTo(score);
	                     now=now+1;});

	now=0;
	duration=synth_rhythm.size;
	while({now<duration},{synthdefs["synth"].note(synth_rhythm.at(now))
			                             .amp_(0.05)
			                             .freq_(synth_pitch.at(now).midicps)
			                             .sus_(synth_length.at(now))
			                             .start_(cutoff_start.at(now))
			                             .end_(cutoff_end.at(now))
			                             .lforate_(lforate.at(now))
			                             .out_(reverb_bus)
			                             .addTo(score);
	                     now=now+1;});

};

score_function.value();

//mode argument determining whether score should be rendered in non-real-time or played directly
	switch(mode,
		"p",{score.play;},
		"w",{score.write(fullpath,
                         duration: (form.size*8)+revtime,
                         options: ServerOptions.new.numOutputBusChannels_(2));}
	      );
	};
);