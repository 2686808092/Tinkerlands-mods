// ModList v@VERSION@ by obfy
OnModUpdate(function()
{
	var _m = ModInstance.Find("ModList");
	if (!ModInstance.Exists(_m))
	{
		_m = ModInstance.Create("ModList", undefined, undefined, undefined, undefined, "");
	}
	if (!variable_instance_exists(_m, "mlReady"))
	{
		_m.mlReady = true;
		_m.mlOpen = true;
		_m.mlNames = [];
		_m.mlFiles = [];
		_m.mlOn = [];
		_m.mlLabels = [];
		_m.mlTick = 9999;
		_m.mlFlash = "";
		_m.mlFlashT = 0;
		_m.mlDebugT = 0;
		_m.mlMsg = "";
		_m.mlMsgT = 0;
		_m.mlErr = "";
		_m.mlNote = "";
		_m.mlForce = false;
		_m.mlCool = 0;
		_m.mlClicked = false;
		_m.mlFolders = [];
		_m.mlSec = 0;
		_m.mlScroll = 0;
		_m.mlView = [];
		_m.mlFolderEdit = false;
		_m.mlEdit = "";
		_m.mlEditKey = "";
		_m.mlEditText = "";
		_m.mlPop = -1;
		_m.mlPopY = 0;
		_m.mlLastClick = -100;
		_m.mlFrame = 0;
		_m.mlBackT = 0;
		_m.mlDelMod = "";
		_m.mlDelModT = 0;
		_m.mlLastTarget = "";
		_m.mlDelArm = 0;

		ini_open("modlist.ini");
		_m.mlSec = ini_read_real("ui", "section", 0);
		_m.mlOpen = ini_read_real("ui", "open", 1) == 1;
		_m.mlPX = ini_read_real("ui", "x", 16);
		_m.mlPY = ini_read_real("ui", "y", 16);
		_m.mlHdrDown = false;
		_m.mlHdrMoved = false;
		_m.mlDownX = 0;
		_m.mlDownY = 0;
		_m.mlSbDrag = false;
		_m.mlSbOff = 0;
		_m.mlSort = ini_read_real("ui", "sort", 0);
		_m.mlAdded = [];
		_m.mlSortKey = [];
		_m.mlItemsSaved = false;
		_m.mlScanJob = undefined;
		_m.mlChecked = {};
		_m.mlScanDirty = false;
		_m.mlScanDone = false;
		_m.mlPopBar = undefined;
		_m.mlPopDrag = false;
		_m.mlPopOff = 0;
		var _fc = ini_read_real("folders", "count", 0);
		for (var _fi = 0; _fi < _fc; _fi++)
		{
			var _fl = ini_read_string("folders", "mods" + string(_fi), "");
			array_push(_m.mlFolders, { name : ini_read_string("folders", "name" + string(_fi), "Folder"), mods : (_fl == "") ? [] : string_split(_fl, "|") });
		}
		ini_close();
	}
	// Rebuild measured labels immediately when the game language changes.
	var _locale = ModList_Language();
	if (!variable_instance_exists(_m, "mlLocale") || _m.mlLocale != _locale)
	{
		_m.mlLocale = _locale;
		_m.mlTick = 9999;
	}
	_m.mlFrame += 1;
	if (_m.mlDelModT > 0)
	{
		_m.mlDelModT -= 1;
		if (_m.mlDelModT <= 0)
		{
			_m.mlDelMod = "";
		}
	}
	if (!variable_global_exists("__ML_NOOP__"))
	{
		variable_global_set("__ML_NOOP__", function() {});
	}
	if (variable_global_exists("__ML_RELOADED__") && variable_global_get("__ML_RELOADED__"))
	{
		variable_global_set("__ML_RELOADED__", false);
		_m.mlMsg = "Mods applied";
		_m.mlMsgT = 210;
		_m.mlCool = 120;
	}

	var _has = function(_arr, _v)
	{
		for (var _hi = 0; _hi < array_length(_arr); _hi++)
		{
			if (_arr[_hi] == _v)
			{
				return true;
			}
		}
		return false;
	};
	var _norm = function(_s)
	{
		var _l = string_lower(_s);
		var _o = "";
		for (var _ni = 1; _ni <= string_length(_l); _ni++)
		{
			var _ch = string_char_at(_l, _ni);
			if ((_ch >= "a" && _ch <= "z") || (_ch >= "0" && _ch <= "9"))
			{
				_o += _ch;
			}
		}
		return _o;
	};
	// so "coolmod" still matches CoolMod-1-2.zip
	var _belongs = function(_nPrefix, _nZip)
	{
		if (_nPrefix == "" || _nZip == "")
		{
			return false;
		}
		return (string_pos(_nPrefix, _nZip) == 1 || string_pos(_nZip, _nPrefix) == 1);
	};
	var _keyOf = function(_e)
	{
		if (is_array(_e) && array_length(_e) > 1)
		{
			if (is_string(_e[1]) && string_pos("@", _e[1]) > 1)
			{
				return _e[1];
			}
			if (is_string(_e[0]) && string_pos("@", _e[0]) > 1)
			{
				return _e[0];
			}
		}
		return "";
	};
	var _rowKey = function(_e)
	{
		if (is_array(_e) && array_length(_e) > 1 && is_string(_e[1])) return _e[1];
		if (is_array(_e) && array_length(_e) > 0 && is_string(_e[0])) return _e[0];
		return "";
	};
	var _hasAny = function(_str, _pats)
	{
		for (var _pi = 0; _pi < array_length(_pats); _pi++)
		{
			if (string_pos(_pats[_pi], _str) > 0)
			{
				return true;
			}
		}
		return false;
	};
	var _saveFolders = function(_list)
	{
		ini_open("modlist.ini");
		ini_section_delete("folders");
		ini_write_real("folders", "count", array_length(_list));
		for (var _si = 0; _si < array_length(_list); _si++)
		{
			var _joined = "";
			for (var _sj = 0; _sj < array_length(_list[_si].mods); _sj++)
			{
				_joined += ((_sj > 0) ? "|" : "") + _list[_si].mods[_sj];
			}
			ini_write_string("folders", "name" + string(_si), _list[_si].name);
			ini_write_string("folders", "mods" + string(_si), _joined);
		}
		ini_close();
	};
	var _arrRemove = function(_arr, _v)
	{
		var _out = [];
		for (var _ri = 0; _ri < array_length(_arr); _ri++)
		{
			if (_arr[_ri] != _v)
			{
				array_push(_out, _arr[_ri]);
			}
		}
		return _out;
	};

	if (_m.mlFlashT > 0)
	{
		_m.mlFlashT -= 1;
	}
	if (_m.mlCool > 0)
	{
		_m.mlCool -= 1;
	}
	if (_m.mlDelArm > 0)
	{
		_m.mlDelArm -= 1;
	}

	var _atMenu = instance_exists(objMenuMain);

	// the game's "save file mods don't match" window can list so many mods that its
	// buttons end up off screen. keep the window the same size and scroll the list instead
	_m.mlPopBar = undefined;
	if (_atMenu)
	{
		var _mm = instance_find(objMenuMain, 0);
		var _mcPop = variable_instance_exists(_mm, "menuController") ? _mm.menuController : undefined;
		var _pp = (is_struct(_mcPop) && variable_struct_exists(_mcPop, "popup")) ? _mcPop.popup : undefined;
		if (is_struct(_pp) && variable_struct_exists(_pp, "str") && is_string(_pp.str))
		{
			if (!variable_struct_exists(_pp, "mlBody"))
			{
				var _pl = string_split(_pp.str, "\n");
				_pp.mlBody = [];
				_pp.mlHead = "";
				_pp.mlTag = "";
				_pp.mlTop = 0;
				_pp.mlShown = -1;
				if (array_length(_pl) > 12)
				{
					_pp.mlHead = _pl[0] + "\n" + _pl[1] + "\n";
					for (var _pq = 2; _pq < array_length(_pl); _pq++)
					{
						array_push(_pp.mlBody, _pl[_pq]);
					}
					// the first entry carries the text size tag, keep it for every scroll position
					var _b0 = _pp.mlBody[0];
					if (string_copy(_b0, 1, 7) == "[scale,")
					{
						var _tagEnd = string_pos("]", _b0);
						_pp.mlTag = string_copy(_b0, 1, _tagEnd);
						_pp.mlBody[0] = string_delete(_b0, 1, _tagEnd);
					}
					// long names wrap onto a second line and make the window jump in size,
					// so cut every mod name to 25 characters
					for (var _pt2 = 0; _pt2 < array_length(_pp.mlBody); _pt2++)
					{
						var _ln2 = _pp.mlBody[_pt2];
						var _tags = "";
						while (string_char_at(_ln2, 1) == "[" && string_char_at(_ln2, 2) != "[" && string_pos("]", _ln2) > 0)
						{
							var _te = string_pos("]", _ln2);
							_tags += string_copy(_ln2, 1, _te);
							_ln2 = string_delete(_ln2, 1, _te);
						}
						var _lead = "";
						if (string_char_at(_ln2, 1) == "(" && string_pos(") ", _ln2) > 0)
						{
							var _pe = string_pos(") ", _ln2) + 1;
							_lead = string_copy(_ln2, 1, _pe);
							_ln2 = string_delete(_ln2, 1, _pe);
						}
						if (string_length(_ln2) > 25) _ln2 = string_copy(_ln2, 1, 25) + "...";
						_pp.mlBody[_pt2] = (string_trim(_lead + _ln2) == "") ? "" : _tags + _lead + _ln2;
					}
					// the game's text ends with a line break, drop the empty line it leaves
					var _keepB = [];
					for (var _pk = 0; _pk < array_length(_pp.mlBody); _pk++)
					{
						if (_pp.mlBody[_pk] != "") array_push(_keepB, _pp.mlBody[_pk]);
					}
					_pp.mlBody = _keepB;
				}
			}
			var _bn = array_length(_pp.mlBody);
			// once a button below the list is clicked the game starts loading but keeps the
			// window around for a moment, so stop showing the bar from then on
			var _pgone = (variable_struct_exists(_pp, "wait") && _pp.wait == true) || (variable_struct_exists(_mcPop, "wait") && _mcPop.wait == true);
			// only the "Play anyway" / "Accept" labels count, the game ignores clicks on the rest of the button
			var _pbs = min(display_get_gui_width() / 640, display_get_gui_height() / 360);
			var _pbx = (device_mouse_x_to_gui(0) - display_get_gui_width() * 0.5) / _pbs;
			var _pby = (device_mouse_y_to_gui(0) - display_get_gui_height() * 0.5) / _pbs;
			if (mouse_check_button_pressed(mb_left) && _pby >= 63 && _pby <= 75 && ((_pbx >= -2.5 && _pbx <= 61.5) || (_pbx >= 78 && _pbx <= 112.5))) _pp.mlDone = true;
			if (variable_struct_exists(_pp, "mlDone")) _pgone = true;
			if (_bn > 8 && !_pgone)
			{
				var _vis = 8;
				if (mouse_wheel_up()) _pp.mlTop -= 1;
				if (mouse_wheel_down()) _pp.mlTop += 1;
				// drag the scroll bar (same spot the draw event puts it)
				var _psb = min(display_get_gui_width() / 640, display_get_gui_height() / 360);
				var _ptx = display_get_gui_width() * 0.5 + 111 * _psb;
				var _pt0 = display_get_gui_height() * 0.5 - 38.7 * _psb;
				var _pt1 = display_get_gui_height() * 0.5 + 52.7 * _psb;
				var _pth = max(6 * _psb, (_pt1 - _pt0) * _vis / _bn);
				var _ptop = _pt0 + (_pt1 - _pt0 - _pth) * (clamp(_pp.mlTop, 0, _bn - _vis) / max(1, _bn - _vis));
				var _pmx = device_mouse_x_to_gui(0);
				var _pmy = device_mouse_y_to_gui(0);
				if (mouse_check_button_pressed(mb_left) && _pmx >= _ptx - 6 * _psb && _pmx <= _ptx + 9 * _psb && _pmy >= _pt0 && _pmy <= _pt1)
				{
					_m.mlPopDrag = true;
					_m.mlPopOff = (_pmy >= _ptop && _pmy <= _ptop + _pth) ? (_pmy - _ptop) : _pth * 0.5;
				}
				if (_m.mlPopDrag)
				{
					if (!mouse_check_button(mb_left))
					{
						_m.mlPopDrag = false;
					}
					else
					{
						_pp.mlTop = round((_pmy - _m.mlPopOff - _pt0) / max(1, _pt1 - _pt0 - _pth) * (_bn - _vis));
					}
				}
				_pp.mlTop = clamp(_pp.mlTop, 0, _bn - _vis);
				_m.mlPopBar = [_pp.mlTop, _bn, _vis];
				if (_pp.mlShown != _pp.mlTop)
				{
					_pp.mlShown = _pp.mlTop;
					var _ns = _pp.mlHead + _pp.mlTag;
					for (var _pv = _pp.mlTop; _pv < _pp.mlTop + _vis; _pv++)
					{
						_ns += _pp.mlBody[_pv] + ((_pv < _pp.mlTop + _vis - 1) ? "\n" : "");
					}
					_pp.str = _ns;
				}
			}
		}
	}

	var _X = _m.mlPX;
	var _Y = _m.mlPY;
	var _W = 400;
	var _HH = 30;
	var _SBY = _Y + 34;
	var _SBH = 26;
	var _RY = _SBY + _SBH + 4;
	var _RH = 28;
	var _ROWS = 10;

	var _nSec = 1 + array_length(_m.mlFolders);
	if (_m.mlSec >= _nSec || _m.mlSec < 0)
	{
		_m.mlSec = 0;
	}
	var _custom = _m.mlSec >= 1 && _m.mlSec <= array_length(_m.mlFolders);
	if (!_custom)
	{
		_m.mlFolderEdit = false;
	}

	var _view = [];
	for (var _vi = 0; _vi < array_length(_m.mlNames); _vi++)
	{
		var _show = true;
		if (_custom && !_m.mlFolderEdit)
		{
			_show = _has(_m.mlFolders[_m.mlSec - 1].mods, _m.mlNames[_vi]);
		}
		if (_show)
		{
			array_push(_view, _vi);
		}
	}
	// 0 = A-Z, 1 = newest first
	if (array_length(_m.mlAdded) == array_length(_m.mlNames) && array_length(_m.mlSortKey) == array_length(_m.mlNames))
	{
		// in a folder "newest" means newest added to that folder
		var _rk = _m.mlAdded;
		if (_custom && !_m.mlFolderEdit)
		{
			_rk = array_create(array_length(_m.mlNames), -1);
			var _fol = _m.mlFolders[_m.mlSec - 1].mods;
			for (var _ra = 0; _ra < array_length(_fol); _ra++)
			{
				for (var _rb = 0; _rb < array_length(_m.mlNames); _rb++)
				{
					if (_m.mlNames[_rb] == _fol[_ra]) _rk[_rb] = _ra;
				}
			}
		}
		for (var _sa = 1; _sa < array_length(_view); _sa++)
		{
			var _sv = _view[_sa];
			var _sb = _sa - 1;
			while (_sb >= 0)
			{
				var _so = _view[_sb];
				var _goes = (_m.mlSort == 1) ? (_rk[_sv] > _rk[_so]) : (_m.mlSortKey[_sv] < _m.mlSortKey[_so]);
				if (!_goes) break;
				_view[_sb + 1] = _so;
				_sb -= 1;
			}
			_view[_sb + 1] = _sv;
		}
	}
	_m.mlView = _view;
	var _maxScroll = max(0, array_length(_view) - _ROWS);
	_m.mlScroll = clamp(_m.mlScroll, 0, _maxScroll);

	if (_atMenu)
	{
		var _mx = device_mouse_x_to_gui(0);
		var _my = device_mouse_y_to_gui(0);
		var _click = mouse_check_button_pressed(mb_left);
		var _commit = false;
		var _cancel = false;

		if (_m.mlEdit != "")
		{
			// keyboard_string doesnt work here
			var _t = _m.mlEditText;
			var _sh = keyboard_check(vk_shift);
			for (var _kc = 65; _kc <= 90; _kc++)
			{
				if (keyboard_check_pressed(_kc))
				{
					_t += _sh ? chr(_kc) : chr(_kc + 32);
				}
			}
			for (var _k2 = 48; _k2 <= 57; _k2++)
			{
				if (!_sh && keyboard_check_pressed(_k2))
				{
					_t += chr(_k2);
				}
			}
			for (var _k3 = 96; _k3 <= 105; _k3++)
			{
				if (keyboard_check_pressed(_k3))
				{
					_t += chr(_k3 - 48);
				}
			}
			if (keyboard_check_pressed(vk_space))
			{
				_t += " ";
			}
			if (keyboard_check_pressed(189))
			{
				_t += _sh ? "_" : "-";
			}
			if (keyboard_check_pressed(190))
			{
				_t += ".";
			}
			if (keyboard_check(vk_backspace))
			{
				if (keyboard_check_pressed(vk_backspace) || _m.mlBackT > 24)
				{
					_t = string_copy(_t, 1, string_length(_t) - 1);
					if (_m.mlBackT > 24)
					{
						_m.mlBackT = 21;
					}
				}
				_m.mlBackT += 1;
			}
			else
			{
				_m.mlBackT = 0;
			}
			if (keyboard_check(vk_control) && keyboard_check_pressed(vk_delete))
			{
				_t = "";
			}
			_m.mlEditText = string_copy(_t, 1, 32);
			if (keyboard_check_pressed(vk_enter))
			{
				_commit = true;
			}
			else if (keyboard_check_pressed(vk_escape))
			{
				_cancel = true;
			}
			else if (_click)
			{
				var _onField = false;
				if (_m.mlEdit == "folder")
				{
					_onField = (_mx >= _X + 26 && _mx <= _X + _W - 200 && _my >= _SBY && _my <= _SBY + _SBH);
				}
				if (!_onField)
				{
					_commit = true;
				}
			}
		}
		if (_commit)
		{
			var _txt = string_trim(_m.mlEditText);
			if (_m.mlEdit == "alias")
			{
				ini_open("modlist.ini");
				if (_txt == "" || _txt == _m.mlEditKey)
				{
					ini_key_delete("alias", _m.mlEditKey);
				}
				else
				{
					ini_write_string("alias", _m.mlEditKey, _txt);
				}
				ini_close();
			}
			else if (_m.mlEdit == "folder")
			{
				var _fx = real(_m.mlEditKey);
				if (_fx < array_length(_m.mlFolders) && _txt != "")
				{
					_m.mlFolders[_fx].name = _txt;
					_saveFolders(_m.mlFolders);
				}
			}
			_m.mlEdit = "";
			_m.mlTick = 9999;
			_click = false;
		}
		if (_cancel)
		{
			_m.mlEdit = "";
		}

		if (_m.mlOpen && _mx >= _X && _mx <= _X + _W && _my >= _RY && _my <= _RY + _ROWS * _RH)
		{
			if (mouse_wheel_up())
			{
				_m.mlScroll = max(0, _m.mlScroll - 1);
			}
			if (mouse_wheel_down())
			{
				_m.mlScroll = min(_maxScroll, _m.mlScroll + 1);
			}
		}

		var _held = mouse_check_button(mb_left);

		if (_click && _m.mlEdit == "" && _m.mlOpen && _mx >= _X + _W - 96 && _mx <= _X + _W - 6 && _my >= _Y + 4 && _my <= _Y + _HH - 4)
		{
			_m.mlSort = 1 - _m.mlSort;
			_m.mlScroll = 0;
			ini_open("modlist.ini");
			ini_write_real("ui", "sort", _m.mlSort);
			ini_close();
			_click = false;
		}

		// grab the header to move the panel, a plain click still opens/closes it
		if (_click && _m.mlEdit == "" && _mx >= _X && _mx <= _X + _W && _my >= _Y && _my <= _Y + _HH)
		{
			_m.mlHdrDown = true;
			_m.mlHdrMoved = false;
			_m.mlDownX = _mx;
			_m.mlDownY = _my;
			_m.mlPop = -1;
			_click = false;
		}
		if (_m.mlHdrDown)
		{
			if (abs(_mx - _m.mlDownX) + abs(_my - _m.mlDownY) > 4) _m.mlHdrMoved = true;
			if (_m.mlHdrMoved)
			{
				_m.mlPX = clamp(_m.mlPX + (_mx - _m.mlDownX), 0, max(0, display_get_gui_width() - _W));
				_m.mlPY = clamp(_m.mlPY + (_my - _m.mlDownY), 0, max(0, display_get_gui_height() - _HH));
				_m.mlDownX = _mx;
				_m.mlDownY = _my;
			}
			if (!_held)
			{
				_m.mlHdrDown = false;
				ini_open("modlist.ini");
				if (_m.mlHdrMoved)
				{
					ini_write_real("ui", "x", _m.mlPX);
					ini_write_real("ui", "y", _m.mlPY);
				}
				else
				{
					_m.mlOpen = !_m.mlOpen;
					ini_write_real("ui", "open", _m.mlOpen ? 1 : 0);
				}
				ini_close();
			}
		}

		// scrollbar
		var _sbN = array_length(_view);
		var _sbH = _ROWS * _RH - 2;
		var _sbT = max(16, _sbH * _ROWS / max(1, _sbN));
		if (_click && _m.mlOpen && _sbN > _ROWS && _mx >= _X + _W - 8 && _mx <= _X + _W + 6 && _my >= _RY && _my <= _RY + _sbH)
		{
			var _sbY = _RY + (_sbH - _sbT) * (_m.mlScroll / (_sbN - _ROWS));
			_m.mlSbOff = (_my >= _sbY && _my <= _sbY + _sbT) ? (_my - _sbY) : _sbT * 0.5;
			_m.mlSbDrag = true;
			_click = false;
		}
		if (_m.mlSbDrag)
		{
			if (!_held || _sbN <= _ROWS || !_m.mlOpen)
			{
				_m.mlSbDrag = false;
			}
			else
			{
				var _sbF = (_my - _m.mlSbOff - _RY) / max(1, _sbH - _sbT);
				_m.mlScroll = clamp(round(_sbF * (_sbN - _ROWS)), 0, _sbN - _ROWS);
			}
		}

		// + popup
		if (_click && _m.mlPop >= 0)
		{
			var _px = (_X + _W + 182 > display_get_gui_width()) ? _X - 176 : _X + _W + 6;
			var _pw = 170;
			var _ph = 22;
			var _pn = max(1, array_length(_m.mlFolders));
			if (_mx >= _px && _mx <= _px + _pw && _my >= _m.mlPopY && _my < _m.mlPopY + _pn * _ph && array_length(_m.mlFolders) > 0)
			{
				var _pf = floor((_my - _m.mlPopY) / _ph);
				var _pmod = _m.mlNames[_m.mlPop];
				if (_has(_m.mlFolders[_pf].mods, _pmod))
				{
					_m.mlFolders[_pf].mods = _arrRemove(_m.mlFolders[_pf].mods, _pmod);
				}
				else
				{
					array_push(_m.mlFolders[_pf].mods, _pmod);
				}
				_saveFolders(_m.mlFolders);
			}
			else
			{
				_m.mlPop = -1;
			}
			_click = false;
		}

		if (_click)
		{
			if (_m.mlOpen && _my >= _SBY && _my <= _SBY + _SBH && _mx >= _X && _mx <= _X + _W)
			{
				var _newSec = _m.mlSec;
				if (_mx <= _X + 24)
				{
					_newSec = (_m.mlSec + _nSec - 1) mod _nSec;
				}
				else if (_mx >= _X + _W - 198 && _mx <= _X + _W - 176)
				{
					_newSec = (_m.mlSec + 1) mod _nSec;
				}
				else if (_custom && !_m.mlFolderEdit && _mx >= _X + _W - 172 && _mx <= _X + _W - 128)
				{
					// whole folder on/off, only the mods in this folder
					var _fm = _m.mlFolders[_m.mlSec - 1].mods;
					var _anyOn = false;
					for (var _fa = 0; _fa < array_length(_m.mlNames); _fa++)
					{
						if (_m.mlOn[_fa] && _has(_fm, _m.mlNames[_fa])) _anyOn = true;
					}
					ini_open("modlist.ini");
					for (var _fb = 0; _fb < array_length(_m.mlNames); _fb++)
					{
						if (_has(_fm, _m.mlNames[_fb]))
						{
							_m.mlOn[_fb] = !_anyOn;
							ini_write_string("want", _m.mlNames[_fb], _anyOn ? "off" : "on");
						}
					}
					ini_close();
					_m.mlTick = 9999;
					_m.mlForce = true;
					_m.mlClicked = true;
				}
				else if (_mx >= _X + _W - 124 && _mx <= _X + _W - 84)
				{
					array_push(_m.mlFolders, { name : "New Folder", mods : [] });
					_saveFolders(_m.mlFolders);
					_newSec = array_length(_m.mlFolders);
					_m.mlSec = _newSec;
					_m.mlFolderEdit = true;
					_m.mlEdit = "folder";
					_m.mlEditKey = string(array_length(_m.mlFolders) - 1);
					_m.mlEditText = "New Folder";
				}
				else if (_m.mlSec == 0 && _mx >= _X + _W - 82)
				{
					// all on / all off
					var _allOn = (_mx < _X + _W - 38);
					ini_open("modlist.ini");
					for (var _aa = 0; _aa < array_length(_m.mlNames); _aa++)
					{
						_m.mlOn[_aa] = _allOn;
						ini_write_string("want", _m.mlNames[_aa], _allOn ? "on" : "off");
					}
					ini_close();
					_m.mlTick = 9999;
					_m.mlForce = true;
					_m.mlClicked = true;
				}
				else if (_custom && _mx >= _X + _W - 80 && _mx <= _X + _W - 40)
				{
					_m.mlFolderEdit = !_m.mlFolderEdit;
					_m.mlScroll = 0;
				}
				else if (_custom && _mx >= _X + _W - 36)
				{
					if (_m.mlDelArm > 0)
					{
						array_delete(_m.mlFolders, _m.mlSec - 1, 1);
						_saveFolders(_m.mlFolders);
						_newSec = 0;
						_m.mlDelArm = 0;
					}
					else
					{
						_m.mlDelArm = 120;
					}
				}
				else if (_custom && _mx > _X + 26 && _mx < _X + _W - 200)
				{
					// double click the tab name to rename the folder
					var _tgt = "sec" + string(_m.mlSec);
					if (_m.mlLastTarget == _tgt && _m.mlFrame - _m.mlLastClick < 24)
					{
						_m.mlEdit = "folder";
						_m.mlEditKey = string(_m.mlSec - 1);
						_m.mlEditText = _m.mlFolders[_m.mlSec - 1].name;
						_m.mlLastTarget = "";
					}
					else
					{
						_m.mlLastTarget = _tgt;
						_m.mlLastClick = _m.mlFrame;
					}
				}
				if (_newSec != _m.mlSec)
				{
					_m.mlSec = _newSec;
					_m.mlScroll = 0;
					_m.mlFolderEdit = false;
					_m.mlDelArm = 0;
				}
				ini_open("modlist.ini");
				ini_write_real("ui", "section", _m.mlSec);
				ini_close();
			}
			else if (_m.mlOpen && _my >= _RY && _my < _RY + _ROWS * _RH && _mx >= _X && _mx <= _X + _W)
			{
				var _row = floor((_my - _RY) / _RH);
				var _vp = _row + _m.mlScroll;
				if (_vp < array_length(_view))
				{
					var _mi = _view[_vp];
					var _base = _m.mlNames[_mi];
					if (_mx >= _X + 6 && _mx <= _X + 50)
					{
						var _newOn = !_m.mlOn[_mi];
						ini_open("modlist.ini");
						ini_write_string("want", _base, _newOn ? "on" : "off");
						ini_close();
						_m.mlOn[_mi] = _newOn;
						_m.mlFlash = _base;
						_m.mlFlashT = 20;
						_m.mlTick = 9999;
						_m.mlForce = true;
						_m.mlClicked = true;
					}
					else if (_custom && !_m.mlFolderEdit && _mx >= _X + _W - 70 && _mx < _X + _W - 38)
					{
						// remove from folder (2 clicks)
						if (_m.mlDelMod != _base)
						{
							_m.mlDelMod = _base;
							_m.mlDelModT = 180;
						}
						else
						{
							_m.mlDelMod = "";
							_m.mlDelModT = 0;
							var _fo = _m.mlFolders[_m.mlSec - 1];
							_fo.mods = _arrRemove(_fo.mods, _base);
							_saveFolders(_m.mlFolders);
							_m.mlMsg = "Removed from " + _fo.name;
							_m.mlMsgT = 150;
						}
					}
					else if (_mx >= _X + _W - 36)
					{
						if (_m.mlSec == 0)
						{
							_m.mlPop = _mi;
							_m.mlPopY = _RY + _row * _RH;
						}
						else if (_custom && _m.mlFolderEdit)
						{
							var _fold = _m.mlFolders[_m.mlSec - 1];
							if (_has(_fold.mods, _base))
							{
								_fold.mods = _arrRemove(_fold.mods, _base);
							}
							else
							{
								array_push(_fold.mods, _base);
							}
							_saveFolders(_m.mlFolders);
						}
					}
					else
					{
						var _tgt2 = "mod" + _base;
						if (_m.mlLastTarget == _tgt2 && _m.mlFrame - _m.mlLastClick < 24)
						{
							ini_open("modlist.ini");
							var _cur = ini_read_string("alias", _base, _base);
							ini_close();
							_m.mlEdit = "alias";
							_m.mlEditKey = _base;
							_m.mlEditText = _cur;
							_m.mlLastTarget = "";
						}
						else
						{
							_m.mlLastTarget = _tgt2;
							_m.mlLastClick = _m.mlFrame;
						}
					}
				}
			}
		}
	}

	// look inside each mod so we know exactly what it owns instead of guessing from the
	// file name. done a bit per frame and kept in modlist.ini, so it only happens again
	// if a mod changes
	if (_atMenu)
	{
		if (!variable_global_exists("__ML_SCAN__"))
		{
			variable_global_set("__ML_SCAN__", {});
		}
		var _scanS = variable_global_get("__ML_SCAN__");
		var _qt = chr(34);
		var _t0 = get_timer();
		while (get_timer() - _t0 < 3000)
		{
			var _job = _m.mlScanJob;
			if (!is_struct(_job))
			{
				var _next = "";
				var _nsz = -1;
				for (var _sf = 0; _sf < array_length(_m.mlFiles); _sf++)
				{
					var _fnm = _m.mlFiles[_sf];
					if (variable_struct_exists(_m.mlChecked, _fnm)) continue;
					var _fsz = -1;
					var _bf = file_bin_open("mods/" + _fnm, 0);
					if (_bf != -1)
					{
						_fsz = file_bin_size(_bf);
						file_bin_close(_bf);
					}
					if (!variable_struct_exists(_scanS, _fnm))
					{
						ini_open("modlist.ini");
						var _enc = ini_read_string("scan", _fnm, "");
						ini_close();
						if (_enc != "")
						{
							var _pj = json_parse(base64_decode(_enc));
							if (is_struct(_pj)) variable_struct_set(_scanS, _fnm, _pj);
						}
					}
					var _old = variable_struct_exists(_scanS, _fnm) ? variable_struct_get(_scanS, _fnm) : undefined;
					if (_fsz >= 0 && is_struct(_old) && variable_struct_exists(_old, "size") && _old.size == _fsz)
					{
						variable_struct_set(_m.mlChecked, _fnm, true);
						continue;
					}
					_next = _fnm;
					_nsz = _fsz;
					break;
				}
				if (_next == "") break;
				var _dir = "modlist_scan/";
				if (directory_exists(_dir)) directory_destroy(_dir);
				_job = { file : _next, paths : [], dbs : [], i : 0, info : { ok : false, size : _nsz, keys : [], skeys : [], pre : [] } };
				if (zip_unzip("mods/" + _next, _dir) > 0)
				{
					_job.info.ok = true;
					var _subs = [];
					var _sn = file_find_first(_dir + "*", fa_directory);
					while (_sn != "")
					{
						if (_sn != "." && _sn != ".." && directory_exists(_dir + _sn)) array_push(_subs, _sn);
						_sn = file_find_next();
					}
					file_find_close();
					for (var _su = 0; _su < array_length(_subs); _su++)
					{
						var _sub = _subs[_su];
						var _sup = string_upper(_sub);
						// "items" -> __DB_ITEM, "interactables" -> __DB_INTERACTABLE etc
						var _dbu = "";
						if (variable_global_exists("__DB_" + string_copy(_sup, 1, string_length(_sup) - 1))) _dbu = string_copy(_sup, 1, string_length(_sup) - 1);
						else if (variable_global_exists("__DB_" + string_copy(_sup, 1, string_length(_sup) - 2))) _dbu = string_copy(_sup, 1, string_length(_sup) - 2);
						else if (variable_global_exists("__DB_" + _sup)) _dbu = _sup;
						if (_dbu == "") continue;
						var _jn = file_find_first(_dir + _sub + "/*.json", 0);
						while (_jn != "")
						{
							array_push(_job.paths, _dir + _sub + "/" + _jn);
							array_push(_job.dbs, _dbu);
							_jn = file_find_next();
						}
						file_find_close();
					}
				}
				_m.mlScanJob = _job;
				continue;
			}
			if (_job.i < array_length(_job.paths))
			{
				var _jk = "";
				var _fh2 = file_text_open_read(_job.paths[_job.i]);
				if (_fh2 != -1)
				{
					while (!file_text_eof(_fh2) && _jk == "")
					{
						var _ln = file_text_read_string(_fh2);
						file_text_readln(_fh2);
						var _kp = string_pos(_qt + "key" + _qt, _ln);
						if (_kp > 0)
						{
							var _rest = string_delete(_ln, 1, _kp + 4);
							var _q1 = string_pos(_qt, _rest);
							if (_q1 > 0)
							{
								_rest = string_delete(_rest, 1, _q1);
								var _q2 = string_pos(_qt, _rest);
								if (_q2 > 1) _jk = string_copy(_rest, 1, _q2 - 1);
							}
						}
					}
					file_text_close(_fh2);
				}
				if (_jk != "")
				{
					var _jd = _job.dbs[_job.i];
					if (_jd == "SCRIPT") array_push(_job.info.skeys, _jk);
					else array_push(_job.info.keys, _jd + "|" + _jk);
					var _at = string_pos("@", _jk);
					if (_at > 1 && !_has(_job.info.pre, string_copy(_jk, 1, _at - 1))) array_push(_job.info.pre, string_copy(_jk, 1, _at - 1));
				}
				_job.i += 1;
			}
			else
			{
				directory_destroy("modlist_scan/");
				variable_struct_set(_scanS, _job.file, _job.info);
				variable_struct_set(_m.mlChecked, _job.file, true);
				_m.mlScanJob = undefined;
				_m.mlScanDirty = true;
			}
		}
		var _allDone = !is_struct(_m.mlScanJob);
		for (var _ad2 = 0; _ad2 < array_length(_m.mlFiles) && _allDone; _ad2++)
		{
			if (!variable_struct_exists(_m.mlChecked, _m.mlFiles[_ad2])) _allDone = false;
		}
		_m.mlScanDone = _allDone && array_length(_m.mlFiles) > 0;
		if (_allDone && _m.mlScanDirty)
		{
			_m.mlScanDirty = false;
			ini_open("modlist.ini");
			ini_section_delete("scan");
			for (var _kf = 0; _kf < array_length(_m.mlFiles); _kf++)
			{
				if (variable_struct_exists(_scanS, _m.mlFiles[_kf])) ini_write_string("scan", _m.mlFiles[_kf], base64_encode(json_stringify(variable_struct_get(_scanS, _m.mlFiles[_kf]))));
			}
			ini_close();
		}
	}

	_m.mlTick += 1;
	if (_m.mlTick < 30) return;
	_m.mlTick = 0;

	var _names = [];
	var _files = [];
	var _on = [];
	var _added = [];
	var _selfFiles = [];
	var _loadedAll = variable_global_get("__MOD_LIST__");
	if (!is_array(_loadedAll)) _loadedAll = [];
	var _skipExt = ["txt", "ini", "md", "png", "jpg", "jpeg", "gif", "json", "log", "bat", "cmd", "exe", "dll", "url", "lnk", "rar", "7z", "off", "bak"];
	var _fn0 = file_find_first("mods/*", fa_none);
	ini_open("modlist.ini");
	while (_fn0 != "")
	{
		var _low = string_lower(_fn0);
		var _base = "";
		var _dot = string_last_pos(".", _low);
		var _ext = (_dot > 0) ? string_copy(_low, _dot + 1, string_length(_low) - _dot) : "";
		// .zip and .mod are both zips, and some mods come with no extension at all
		if (_ext == "zip" || _ext == "mod")
		{
			_base = string_copy(_fn0, 1, _dot - 1);
		}
		else if (_has(_loadedAll, _fn0) || !_has(_skipExt, _ext))
		{
			_base = _fn0;
		}
		if (_base != "")
		{
			if (string_pos("modlist", _low) == 1)
			{
				array_push(_selfFiles, _fn0);
			}
			else if (!_has(_names, _base))
			{
				var _want = ini_read_string("want", _base, "");
				array_push(_names, _base);
				array_push(_files, _fn0);
				array_push(_on, _want != "off");
				var _ad = ini_read_real("added", _base, -1);
				if (_ad < 0)
				{
					_ad = ini_read_real("ui", "added", 0) + 1;
					ini_write_real("ui", "added", _ad);
					ini_write_real("added", _base, _ad);
				}
				array_push(_added, _ad);
			}
		}
		_fn0 = file_find_next();
	}
	file_find_close();
	ini_close();
	if (array_length(_names) == 0 && array_length(_selfFiles) == 0)
	{
		_m.mlErr = "Could not read the mods folder";
		return;
	}
	_m.mlErr = "";

	var _loaded = variable_global_get("__MOD_LIST__");
	if (!is_array(_loaded))
	{
		_loaded = [];
	}
	var _needReload = [];
	var _anyReload = false;
	for (var _a = 0; _a < array_length(_names); _a++)
	{
		var _nr = _on[_a] && !_has(_loaded, _files[_a]);
		array_push(_needReload, _nr);
		if (_nr)
		{
			_anyReload = true;
		}
	}
	_m.mlNames = _names;
	_m.mlFiles = _files;
	_m.mlOn = _on;
	_m.mlAdded = _added;

	var _labelFont = draw_get_font();
	var _labelFont = draw_get_font();
	draw_set_font(ModList_Font());
	ini_open("modlist.ini");
	var _labels = [];
	var _keys = [];
	for (var _lb = 0; _lb < array_length(_names); _lb++)
	{
		var _t = ini_read_string("alias", _names[_lb], _names[_lb]);
		array_push(_keys, string_lower(_t));
		var _suffix = _needReload[_lb] ? ModList_Text("  (loading...)") : "";
		var _maxw = 262 / 0.45;
		if (string_width(_t + _suffix) > _maxw)
		{
			var _cut = string_length(_t);
			while (_cut > 1 && string_width(string_copy(_t, 1, _cut) + "..." + _suffix) > _maxw)
			{
				_cut -= 1;
			}
			_t = string_copy(_t, 1, _cut) + "...";
		}
		array_push(_labels, _t + _suffix);
	}
	ini_close();
	_m.mlLabels = _labels;
	_m.mlSortKey = _keys;
	draw_set_font(_labelFont);
	draw_set_font(_labelFont);

	if (!_atMenu) return;

	var _scan = variable_global_exists("__ML_SCAN__") ? variable_global_get("__ML_SCAN__") : {};

	// mod was never loaded, have to reload everything
	if (_anyReload && (_m.mlCool <= 0 || _m.mlForce))
	{
		var _desired = [];
		for (var _s = 0; _s < array_length(_selfFiles); _s++)
		{
			array_push(_desired, _selfFiles[_s]);
		}
		for (var _d = 0; _d < array_length(_files); _d++)
		{
			if (_on[_d])
			{
				array_push(_desired, _files[_d]);
			}
		}
		var _order = [];
		var _fn1 = file_find_first("mods/*", fa_none);
		while (_fn1 != "")
		{
			if (_has(_desired, _fn1))
			{
				array_push(_order, _fn1);
			}
			_fn1 = file_find_next();
		}
		file_find_close();
		var _f_unload = variable_global_get("mod_unload_all");
		var _f_init = variable_global_get("mod_initialize");
		var _f_revert = variable_global_get("database_revert_to_original");
		var _f_load = variable_global_get("mod_load");
		var _f_mat0 = variable_global_get("__rebuild_material_list");
		var _f_set0 = variable_global_get("__rebuild_set_list");
		var _f_buff0 = variable_global_get("__compile_buffs");
		var _f_api = variable_global_get("modapi_load");
		if (!is_callable(_f_load)) return;
		_m.mlCool = 120;
		_m.mlForce = false;
		_f_unload();
		_f_init();
		_f_revert();
		for (var _k = 0; _k < array_length(_order); _k++)
		{
			_f_load("mods\\" + _order[_k]);
		}
		variable_global_set("__MOD_LIST__", _order);
		_f_mat0();
		_f_set0();
		_f_buff0();
		var _sc0 = variable_global_get("__DB_SCRIPT");
		var _src = "";
		for (var _q = 1; _q < array_length(_sc0); _q++)
		{
			var _e0 = _sc0[_q];
			if (is_array(_e0) && array_length(_e0) > 4 && is_string(_e0[4]))
			{
				_src += _e0[4] + "\n";
			}
		}
		variable_global_set("__ML_SNAP__", undefined);
		variable_global_set("__ML_APPLIED__", "");
		variable_global_set("__ML_RELOADED__", true);
		_f_api("mod", _src);
		return;
	}
	_m.mlForce = false;

	// snapshot of the dbs with everything loaded
	var _listKey = string(_loaded);
	var _snap = variable_global_exists("__ML_SNAP__") ? variable_global_get("__ML_SNAP__") : undefined;
	if (!is_struct(_snap) || _snap.list != _listKey)
	{
		_snap = { list : _listKey, dbs : [], prefixes : [] };
		var _dbn = variable_global_get("__DBS_NAMES__");
		for (var _n = 0; _n < array_length(_dbn); _n++)
		{
			var _up = string_upper(string_replace(_dbn[_n], "db_", ""));
			if (_up != "SCRIPT" && variable_global_exists("__DB_" + _up) && variable_global_exists("__DB_" + _up + "_ORIGINAL_COUNT"))
			{
				var _A = variable_global_get("__DB_" + _up);
				if (is_array(_A))
				{
					var _cnt = variable_global_get("__DB_" + _up + "_ORIGINAL_COUNT");
					var _len = array_length(_A);
					var _copy = array_create(_len, 0);
					array_copy(_copy, 0, _A, 0, _len);
					// vanilla rows that reference modded keys
					var _vidx = [];
					var _vkeys = [];
					var _vlim = min(_cnt + 1, _len);
					for (var _v = 0; _v < _vlim; _v++)
					{
						array_push(_vkeys, _rowKey(_A[_v]));
						if (string_pos("@", string(_A[_v])) > 0)
						{
							array_push(_vidx, _v);
						}
					}
					var _mkeys = [];
					var _rkeys = [];
					for (var _i = _cnt + 1; _i < _len; _i++)
					{
						var _ky = _keyOf(_A[_i]);
						array_push(_mkeys, _ky);
						array_push(_rkeys, _rowKey(_A[_i]));
						if (_ky != "")
						{
							var _pf = string_copy(_ky, 1, string_pos("@", _ky) - 1);
							if (!_has(_snap.prefixes, _pf))
							{
								array_push(_snap.prefixes, _pf);
							}
						}
					}
					var _dname = "__DICTIONARY_DB_" + _up + "__";
					var _dkeys = [];
					if (variable_global_exists(_dname))
					{
						var _dict = variable_global_get(_dname);
						if (_len <= _cnt + 1)
						{
							// nothing appended, nothing to track
						}
						else if (ds_exists(_dict, ds_type_map))
						{
							var _dk = ds_map_find_first(_dict);
							while (!is_undefined(_dk))
							{
								var _dv = ds_map_find_value(_dict, _dk);
								if (is_string(_dk) && (string_pos("@", _dk) > 0 || (is_real(_dv) && _dv > _cnt)))
								{
									array_push(_dkeys, _dk);
								}
								_dk = ds_map_find_next(_dict, _dk);
							}
						}
						else
						{
							_dname = "";
						}
					}
					else
					{
						_dname = "";
					}
					array_push(_snap.dbs, { up : _up, arr : _copy, cnt : _cnt, vidx : _vidx, vkeys : _vkeys, mkeys : _mkeys, rkeys : _rkeys, dname : _dname, dkeys : _dkeys, dirty : false });
				}
			}
		}
		variable_global_set("__ML_SNAP__", _snap);
		variable_global_set("__ML_APPLIED__", "");
	}

	var _off = [];
	var _offPat = [];
	var _offZips = [];
	var _kOwn = {};
	var _sOwn = {};
	var _offF = {};
	var _offDb = {};
	for (var _z = 0; _z < array_length(_names); _z++)
	{
		var _inf = variable_struct_exists(_scan, _files[_z]) ? variable_struct_get(_scan, _files[_z]) : undefined;
		var _known = is_struct(_inf) && _inf.ok;
		if (!_on[_z])
		{
			variable_struct_set(_offF, _files[_z], true);
			array_push(_off, _files[_z]);
			if (!_known) array_push(_offZips, _norm(_names[_z]));
		}
		if (_known)
		{
			for (var _kq = 0; _kq < array_length(_inf.keys); _kq++) variable_struct_set(_kOwn, _inf.keys[_kq], _files[_z]);
			for (var _kr = 0; _kr < array_length(_inf.skeys); _kr++) variable_struct_set(_sOwn, _inf.skeys[_kr], _files[_z]);
			if (!_on[_z])
			{
				for (var _kd = 0; _kd < array_length(_inf.keys); _kd++)
				{
					var _kbar = string_pos("|", _inf.keys[_kd]);
					if (_kbar > 1) variable_struct_set(_offDb, string_copy(_inf.keys[_kd], 1, _kbar - 1), true);
				}
				for (var _ks = 0; _ks < array_length(_inf.pre); _ks++)
				{
					if (!_has(_offPat, _inf.pre[_ks] + "@")) array_push(_offPat, _inf.pre[_ks] + "@");
				}
			}
		}
	}
	// a mod we couldn't open still gets matched by its name
	for (var _p = 0; _p < array_length(_snap.prefixes); _p++)
	{
		var _np = _norm(_snap.prefixes[_p]);
		for (var _oz = 0; _oz < array_length(_offZips); _oz++)
		{
			if (_belongs(_np, _offZips[_oz]) && !_has(_offPat, _snap.prefixes[_p] + "@")) array_push(_offPat, _snap.prefixes[_p] + "@");
		}
	}
	// items from mods that are turned off or deleted. a save holding one of them crashes the
	// game when it loads, so these get a blank stand-in with the same name instead
	var _phOff = [];
	var _phDel = [];
	ini_open("modlist.ini");
	var _il = ini_read_string("items", "_list", "");
	var _ila = (_il == "") ? [] : string_split(_il, "|");
	// remember every item each mod adds, so deleted mods can still be covered later
	if (_m.mlScanDone && !_m.mlItemsSaved)
	{
		_m.mlItemsSaved = true;
		for (var _iz = 0; _iz < array_length(_files); _iz++)
		{
			var _iinf = variable_struct_exists(_scan, _files[_iz]) ? variable_struct_get(_scan, _files[_iz]) : undefined;
			if (is_struct(_iinf) && _iinf.ok)
			{
				var _ik = "";
				for (var _ix2 = 0; _ix2 < array_length(_iinf.keys); _ix2++)
				{
					if (string_copy(_iinf.keys[_ix2], 1, 5) == "ITEM|") _ik += ((_ik == "") ? "" : "|") + string_delete(_iinf.keys[_ix2], 1, 5);
				}
				// keep keys this mod had before too, so items removed from it stay covered
				var _iold = string_split(ini_read_string("items", _names[_iz], ""), "|");
				for (var _io2 = 0; _io2 < array_length(_iold); _io2++)
				{
					if (_iold[_io2] != "" && !_has(string_split(_ik, "|"), _iold[_io2])) _ik += ((_ik == "") ? "" : "|") + _iold[_io2];
				}
				if (_ik != "")
				{
					ini_write_string("items", _names[_iz], _ik);
					if (!_has(_ila, _names[_iz])) array_push(_ila, _names[_iz]);
				}
			}
		}
		var _ilj = "";
		for (var _ij = 0; _ij < array_length(_ila); _ij++)
		{
			_ilj += ((_ij > 0) ? "|" : "") + _ila[_ij];
		}
		ini_write_string("items", "_list", _ilj);
	}
	for (var _id2 = 0; _id2 < array_length(_ila); _id2++)
	{
		var _ib = _ila[_id2];
		var _ion = _has(_names, _ib);
		var _ioff = false;
		var _inow = undefined;
		for (var _io = 0; _io < array_length(_names); _io++)
		{
			if (_names[_io] == _ib)
			{
				if (!_on[_io]) _ioff = true;
				_inow = variable_struct_exists(_scan, _files[_io]) ? variable_struct_get(_scan, _files[_io]) : undefined;
			}
		}
		var _iks = string_split(ini_read_string("items", _ib, ""), "|");
		for (var _iq = 0; _iq < array_length(_iks); _iq++)
		{
			if (_iks[_iq] == "") continue;
			if (!_ion) array_push(_phDel, [_iks[_iq], _ib]);
			else if (_ioff) array_push(_phOff, [_iks[_iq], _ib]);
			// mod is on but no longer has this item (only trusted once that mod is scanned)
			else if (is_struct(_inow) && _inow.ok && !_has(_inow.keys, "ITEM|" + _iks[_iq])) array_push(_phOff, [_iks[_iq], _ib]);
		}
	}
	ini_close();
	var _phAll = [];
	for (var _ia = 0; _ia < array_length(_phOff); _ia++) array_push(_phAll, _phOff[_ia]);
	for (var _ib2 = 0; _ib2 < array_length(_phDel); _ib2++) array_push(_phAll, _phDel[_ib2]);

	var _offKey = string(_off) + string(_offPat) + string(_phAll) + (_m.mlScanDone ? "" : "?");

	if (variable_global_get("__ML_APPLIED__") == _offKey && _m.mlClicked)
	{
		_m.mlMsg = "Mods applied";
		_m.mlMsgT = 210;
	}

	// strip disabled stuff out of the dbs
	if (variable_global_get("__ML_APPLIED__") != _offKey && (_m.mlScanDone || _m.mlClicked))
	{
		for (var _b = 0; _b < array_length(_snap.dbs); _b++)
		{
			var _sd = _snap.dbs[_b];
			// leave dbs alone that nothing disabled touches (and that weren't changed last time)
			var _needs = variable_struct_exists(_offDb, _sd.up) || (array_length(_offPat) > 0 && (array_length(_sd.arr) > _sd.cnt + 1 || array_length(_sd.vidx) > 0)) || (_sd.up == "ITEM" && array_length(_phAll) > 0);
			if (!_needs && !_sd.dirty) continue;
			_sd.dirty = _needs;
			var _src0 = _sd.arr;
			var _cnt0 = _sd.cnt;
			var _len0 = array_length(_src0);
			var _vl = min(_cnt0 + 1, _len0);
			var _new = array_create(_vl, 0);
			array_copy(_new, 0, _src0, 0, _vl);
			var _orig = variable_global_get("__DB_" + _sd.up + "_ORIGINAL");
			// mods that change a vanilla entry (same key, no prefix) get the original back
			if (is_array(_orig) && variable_struct_exists(_offDb, _sd.up))
			{
				for (var _vr = 0; _vr < _vl; _vr++)
				{
					var _vk = _sd.vkeys[_vr];
					if (_vk == "") continue;
					var _vo = variable_struct_exists(_kOwn, _sd.up + "|" + _vk) ? variable_struct_get(_kOwn, _sd.up + "|" + _vk) : (variable_struct_exists(_kOwn, "*|" + _vk) ? variable_struct_get(_kOwn, "*|" + _vk) : "");
					if (_vo != "" && variable_struct_exists(_offF, _vo) && _vr < array_length(_orig)) _new[_vr] = _orig[_vr];
				}
			}
			if (array_length(_offPat) > 0)
			{
				for (var _vi = 0; _vi < array_length(_sd.vidx); _vi++)
				{
					var _ix = _sd.vidx[_vi];
					var _ent = _new[_ix];
					if (is_array(_ent) && _hasAny(string(_ent), _offPat))
					{
						var _ne = array_create(array_length(_ent), 0);
						array_copy(_ne, 0, _ent, 0, array_length(_ent));
						for (var _f = 0; _f < array_length(_ne); _f++)
						{
							var _fv = _ne[_f];
							if (_hasAny(string(_fv), _offPat))
							{
								if (is_array(_fv))
								{
									var _keep = [];
									for (var _fe = 0; _fe < array_length(_fv); _fe++)
									{
										if (!_hasAny(string(_fv[_fe]), _offPat))
										{
											array_push(_keep, _fv[_fe]);
										}
									}
									_ne[_f] = _keep;
								}
								else if (is_array(_orig) && _ix < array_length(_orig) && is_array(_orig[_ix]) && _f < array_length(_orig[_ix]))
								{
									_ne[_f] = _orig[_ix][_f];
								}
							}
						}
						_new[_ix] = _ne;
					}
				}
			}
			var _dict2 = (_sd.dname != "") ? variable_global_get(_sd.dname) : undefined;
			if (!is_undefined(_dict2))
			{
				for (var _dd = 0; _dd < array_length(_sd.dkeys); _dd++)
				{
					ds_map_delete(_dict2, _sd.dkeys[_dd]);
				}
			}
			var _spareRows = [];
			for (var _mi = _cnt0 + 1; _mi < _len0; _mi++)
			{
				var _mk = _sd.mkeys[_mi - _cnt0 - 1];
				var _rkey = _sd.rkeys[_mi - _cnt0 - 1];
				var _ow = variable_struct_exists(_kOwn, _sd.up + "|" + _rkey) ? variable_struct_get(_kOwn, _sd.up + "|" + _rkey) : (variable_struct_exists(_kOwn, "*|" + _rkey) ? variable_struct_get(_kOwn, "*|" + _rkey) : "");
				var _drop = (_ow != "") ? variable_struct_exists(_offF, _ow) : (_mk != "" && _hasAny(_mk, _offPat));
				// ModList's own spare item slots: they only reserve room, the stand-ins below go there
				if (_sd.up == "ITEM" && (string_pos("Modlist@spare", _mk) == 1 || string_pos("Modlist@spare", _rkey) == 1))
				{
					_drop = true;
					array_push(_spareRows, _src0[_mi]);
					if (!is_undefined(_dict2))
					{
						if (_mk != "") ds_map_delete(_dict2, _mk);
						if (_rkey != "") ds_map_delete(_dict2, _rkey);
					}
				}
				if (!_drop)
				{
					var _me = _src0[_mi];
					var _newIx = array_length(_new);
					array_push(_new, _me);
					if (!is_undefined(_dict2) && _rkey != "" && _rkey != _mk)
					{
						ds_map_set(_dict2, _rkey, _newIx);
					}
					if (!is_undefined(_dict2) && _mk != "")
					{
						ds_map_set(_dict2, _mk, _newIx);
						if (is_array(_me) && is_string(_me[0]) && _me[0] != _mk && string_pos("@", _me[0]) > 0)
						{
							ds_map_set(_dict2, _me[0], _newIx);
						}
					}
				}
			}
			// stand-ins for items whose mod is off or deleted (copied from vanilla Rock, then renamed)
			if (_sd.up == "ITEM" && is_array(_orig) && array_length(_orig) > 3 && is_array(_orig[3]))
			{
				for (var _phi = 0; _phi < array_length(_phAll); _phi++)
				{
					var _phk = _phAll[_phi][0];
					if (!is_undefined(_dict2) && !is_undefined(ds_map_find_value(_dict2, _phk))) continue;
					var _phRow = array_create(array_length(_orig[3]), 0);
					array_copy(_phRow, 0, _orig[3], 0, array_length(_orig[3]));
					_phRow[0] = _phk;
					_phRow[1] = _phk;
					_phRow[2] = "Missing item (" + _phAll[_phi][1] + ")";
					// icon: the game's big gold question mark (sprite name or index, matching how the row stores it)
					var _qmSpr = asset_get_index("sprGUIIngameIconQuestionMark");
					if (array_length(_phRow) > 5 && _qmSpr != -1)
					{
						if (is_string(_phRow[5])) _phRow[5] = "sprGUIIngameIconQuestionMark";
						else _phRow[5] = _qmSpr;
					}
					// description, buy and sell price (only touched if they look like those fields)
					if (array_length(_phRow) > 19 && is_string(_phRow[19])) _phRow[19] = "Its mod is turned off, was deleted, or no longer has this item. Safe to throw away.";
					if (array_length(_phRow) > 25 && is_real(_phRow[24]) && is_real(_phRow[25]))
					{
						_phRow[24] = 0;
						_phRow[25] = 0;
					}
					var _phIx = array_length(_new);
					// never make the item list longer than the game loaded it, the game can't
					// handle items past that point (ModList ships spare slots to make room)
					if (_phIx >= _len0) break;
					array_push(_new, _phRow);
					if (!is_undefined(_dict2)) ds_map_set(_dict2, _phk, _phIx);
				}
			}
			// keep the item list exactly as long as the game loaded it: the game sizes other
			// lists by it, so a shorter or longer one crashes it. gaps get blank spare slots
			if (_sd.up == "ITEM")
			{
				var _padN = 0;
				while (array_length(_new) < _len0)
				{
					if (_padN < array_length(_spareRows)) array_push(_new, _spareRows[_padN]);
					else array_push(_new, _new[array_length(_new) - 1]);
					_padN += 1;
				}
			}
			variable_global_set("__DB_" + _sd.up, _new);
		}
		var _f_mat = variable_global_get("__rebuild_material_list");
		var _f_set = variable_global_get("__rebuild_set_list");
		// NOT __compile_buffs, running it twice breaks buffs
		if (is_callable(_f_mat))
		{
			_f_mat();
		}
		if (is_callable(_f_set))
		{
			_f_set();
		}
		variable_global_set("__ML_APPLIED__", _offKey);
		if (array_length(_off) > 0 || _m.mlClicked)
		{
			_m.mlMsg = "Mods applied";
			_m.mlMsgT = 210;
		}
	}

	_m.mlClicked = false;

	// pause hooks of disabled script mods
	var _mo = instance_exists(objMod) ? instance_find(objMod, 0) : noone;
	var _sc = variable_global_get("__DB_SCRIPT");
	if (_mo != noone && is_array(_sc))
	{
		var _events = ["OnModUpdate", "OnModDraw", "OnModDrawEnd", "OnModDrawGUI", "OnModDrawGUIEnd", "OnPlayerDeath", "OnOtherPlayerDeath", "OnFishingCatch", "OnMobSpawn", "OnMobDespawn", "OnMobDeath", "OnNPCSpawn", "OnCookingEnd", "OnIslandArrive", "OnIslandFirstArrive", "OnMainIslandArrive", "OnInteractableCreate", "OnInteractableDestroy", "OnInteractableHarvest", "OnItemCreate", "OnDayStart", "OnNightStart", "OnWorldGenerationEnd", "OnWorldGenerationStart"];
		var _evNames = variable_instance_get_names(_mo);
		for (var _en = 0; _en < array_length(_evNames); _en++)
		{
			var _enm = _evNames[_en];
			if (string_copy(_enm, 1, 2) == "On" && !_has(_events, _enm) && is_array(variable_instance_get(_mo, _enm))) array_push(_events, _enm);
		}
		var _noop = variable_global_get("__ML_NOOP__");
		var _hk = variable_global_exists("__ML_HOOKS__") ? variable_global_get("__ML_HOOKS__") : undefined;
		var _remap = !is_struct(_hk);
		if (!_remap)
		{
			for (var _e = 0; _e < array_length(_events) && !_remap; _e++)
			{
				var _ha = variable_instance_exists(_mo, _events[_e]) ? variable_instance_get(_mo, _events[_e]) : undefined;
				var _ho = variable_struct_exists(_hk.orig, _events[_e]) ? variable_struct_get(_hk.orig, _events[_e]) : undefined;
				if (is_array(_ha) != is_array(_ho))
				{
					_remap = true;
				}
				else if (is_array(_ha))
				{
					if (array_length(_ha) != array_length(_ho))
					{
						_remap = true;
					}
					else
					{
						for (var _hi2 = 0; _hi2 < array_length(_ha); _hi2++)
						{
							if (_ha[_hi2] != _ho[_hi2] && _ha[_hi2] != _noop)
							{
								_remap = true;
							}
						}
					}
				}
			}
		}
		if (_remap)
		{
			_hk = { orig : {}, owner : {}, bad : 0 };
			for (var _e2 = 0; _e2 < array_length(_events); _e2++)
			{
				var _ev = _events[_e2];
				var _arr = variable_instance_exists(_mo, _ev) ? variable_instance_get(_mo, _ev) : undefined;
				if (is_array(_arr) && array_length(_arr) > 0)
				{
					var _own = [];
					var _pat = _ev + "(";
					for (var _si = 1; _si < array_length(_sc); _si++)
					{
						var _se = _sc[_si];
						if (is_array(_se) && array_length(_se) > 4 && is_string(_se[4]))
						{
							var _code = _se[4];
							var _sk = _rowKey(_se);
							var _pos = string_pos(_pat, _code);
							while (_pos > 0)
							{
								var _ok = true;
								var _ls = _pos;
								while (_ls > 1 && string_char_at(_code, _ls - 1) != chr(10))
								{
									_ls -= 1;
								}
								if (string_pos("//", string_copy(_code, _ls, _pos - _ls)) > 0)
								{
									_ok = false;
								}
								if (_pos > 1)
								{
									var _pc = string_char_at(_code, _pos - 1);
									if ((_pc >= "a" && _pc <= "z") || (_pc >= "A" && _pc <= "Z") || (_pc >= "0" && _pc <= "9") || _pc == "_" || _pc == ".")
									{
										_ok = false;
									}
								}
								if (_ok)
								{
									array_push(_own, _sk);
								}
								_pos = string_pos_ext(_pat, _code, _pos + 1);
							}
						}
					}
					var _oc = array_create(array_length(_arr), 0);
					array_copy(_oc, 0, _arr, 0, array_length(_arr));
					variable_struct_set(_hk.orig, _ev, _oc);
					if (array_length(_own) == array_length(_arr))
					{
						variable_struct_set(_hk.owner, _ev, _own);
					}
					else
					{
						_hk.bad += array_length(_arr);
					}
				}
			}
			variable_global_set("__ML_HOOKS__", _hk);
		}
		_m.mlNote = (_hk.bad > 0) ? (string(_hk.bad) + " hook(s) could not be matched to a mod") : "";

		var _evs = variable_struct_get_names(_hk.owner);
		for (var _e3 = 0; _e3 < array_length(_evs); _e3++)
		{
			var _ev3 = _evs[_e3];
			var _own3 = variable_struct_get(_hk.owner, _ev3);
			var _org3 = variable_struct_get(_hk.orig, _ev3);
			var _cur = variable_instance_get(_mo, _ev3);
			if (is_array(_cur) && array_length(_cur) == array_length(_own3))
			{
				var _chg = false;
				for (var _h = 0; _h < array_length(_own3); _h++)
				{
					var _hOff = false;
					var _hkey = _own3[_h];
					var _hat = string_pos("@", _hkey);
					var _hn = _norm((_hat > 1) ? string_copy(_hkey, 1, _hat - 1) : _hkey);
					if (variable_struct_exists(_sOwn, _hkey))
					{
						_hOff = variable_struct_exists(_offF, variable_struct_get(_sOwn, _hkey));
					}
					else if (_hn != "" && _hn != "modlist")
					{
						for (var _oz2 = 0; _oz2 < array_length(_offZips); _oz2++)
						{
							if (_belongs(_hn, _offZips[_oz2]))
							{
								_hOff = true;
							}
						}
					}
					var _tg = _hOff ? _noop : _org3[_h];
					if (_cur[_h] != _tg)
					{
						_cur[_h] = _tg;
						_chg = true;
					}
				}
				if (_chg)
				{
					variable_instance_set(_mo, _ev3, _cur);
				}
			}
		}
	}
});

OnModDrawGUIEnd(function()
{
	if (!instance_exists(objMenuMain)) return;
	// a world is loading: get out of the way (like the warning window's scroll bar)
	if (instance_exists(objWorldController) || instance_exists(objTransition)) return;
	var _m = ModInstance.Find("ModList");
	if (!ModInstance.Exists(_m) || !variable_instance_exists(_m, "mlReady")) return;

	if (keyboard_check(vk_shift) && keyboard_check_pressed(vk_f1))
	{
		var _lines = ["ModList v@VERSION@ report"];
		array_push(_lines, "mods: " + string(_m.mlNames));
		array_push(_lines, "files: " + string(_m.mlFiles));
		array_push(_lines, "on: " + string(_m.mlOn));
		array_push(_lines, "folders: " + string(_m.mlFolders));
		array_push(_lines, "loaded: " + string(variable_global_get("__MOD_LIST__")));
		var _scn = variable_global_exists("__ML_SCAN__") ? variable_global_get("__ML_SCAN__") : undefined;
		if (is_struct(_scn))
		{
			var _sfn = variable_struct_get_names(_scn);
			for (var _sx = 0; _sx < array_length(_sfn); _sx++)
			{
				var _si = variable_struct_get(_scn, _sfn[_sx]);
				array_push(_lines, "  scan " + _sfn[_sx] + ": " + (_si.ok ? (string(array_length(_si.keys)) + " entries, " + string(array_length(_si.skeys)) + " scripts, prefixes " + string(_si.pre)) : "could not open"));
			}
		}
		array_push(_lines, "disabled content: " + string(variable_global_exists("__ML_APPLIED__") ? variable_global_get("__ML_APPLIED__") : ""));
		// every item key ModList remembers, and whether the game can find it right now
		var _rdict = variable_global_exists("__DICTIONARY_DB_ITEM__") ? variable_global_get("__DICTIONARY_DB_ITEM__") : undefined;
		ini_open("modlist.ini");
		var _rl = string_split(ini_read_string("items", "_list", ""), "|");
		for (var _rq = 0; _rq < array_length(_rl); _rq++)
		{
			if (_rl[_rq] == "") continue;
			var _rks = string_split(ini_read_string("items", _rl[_rq], ""), "|");
			for (var _rk2 = 0; _rk2 < array_length(_rks); _rk2++)
			{
				if (_rks[_rk2] == "") continue;
				var _rv = is_undefined(_rdict) ? "no dict" : ds_map_find_value(_rdict, _rks[_rk2]);
				array_push(_lines, "  item " + _rl[_rq] + " / " + _rks[_rk2] + " -> " + string(_rv));
			}
		}
		ini_close();
		array_push(_lines, "scan done " + string(_m.mlScanDone) + " | items saved " + string(_m.mlItemsSaved));
		// anything else the game keeps per item (its size should match the item list)
		var _gnm = variable_instance_get_names(global);
		for (var _gq = 0; _gq < array_length(_gnm); _gq++)
		{
			var _gv = variable_global_get(_gnm[_gq]);
			if (is_array(_gv) && array_length(_gv) >= 2030 && array_length(_gv) <= 2060) array_push(_lines, "  per-item array " + _gnm[_gq] + " = " + string(array_length(_gv)));
			else if (is_struct(_gv))
			{
				var _gsn = variable_struct_get_names(_gv);
				for (var _gs = 0; _gs < array_length(_gsn); _gs++)
				{
					var _gsv = variable_struct_get(_gv, _gsn[_gs]);
					if (is_array(_gsv) && array_length(_gsv) >= 2030 && array_length(_gsv) <= 2060) array_push(_lines, "  per-item array " + _gnm[_gq] + "." + _gsn[_gs] + " = " + string(array_length(_gsv)));
				}
			}
		}
		var _sn = variable_global_exists("__ML_SNAP__") ? variable_global_get("__ML_SNAP__") : undefined;
		if (is_struct(_sn))
		{
			array_push(_lines, "content prefixes: " + string(_sn.prefixes));
			for (var _i = 0; _i < array_length(_sn.dbs); _i++)
			{
				var _d = _sn.dbs[_i];
				var _cur = variable_global_get("__DB_" + _d.up);
				array_push(_lines, "  " + _d.up + ": " + string(array_length(_d.arr)) + " -> " + string(array_length(_cur)) + "  vanilla refs " + string(_d.vidx));
			}
		}
		var _hk = variable_global_exists("__ML_HOOKS__") ? variable_global_get("__ML_HOOKS__") : undefined;
		if (is_struct(_hk))
		{
			var _ev = variable_struct_get_names(_hk.owner);
			for (var _j = 0; _j < array_length(_ev); _j++)
			{
				array_push(_lines, "  " + _ev[_j] + ": " + string(variable_struct_get(_hk.owner, _ev[_j])));
			}
			array_push(_lines, "  unmatched hooks: " + string(_hk.bad));
		}
		array_push(_lines, "error: " + _m.mlErr + " | note: " + _m.mlNote);
		var _txt = "";
		for (var _w = 0; _w < array_length(_lines); _w++)
		{
			_txt += _lines[_w] + "\n";
		}
		clipboard_set_text(_txt);
		_m.mlDebugT = 300;
	}

	var _X = _m.mlPX;
	var _Y = _m.mlPY;
	var _W = 400;
	var _HH = 30;
	var _SBY = _Y + 34;
	var _SBH = 26;
	var _RY = _SBY + _SBH + 4;
	var _RH = 28;
	var _ROWS = 10;
	var _FY = _RY + _ROWS * _RH + 2;
	var _FH = 22;

	var _mx = device_mouse_x_to_gui(0);
	var _my = device_mouse_y_to_gui(0);
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _caret = (floor(_m.mlFrame / 30) mod 2 == 0) ? "|" : "";
	var _colBg = make_color_rgb(20, 18, 30);
	var _colHi = make_color_rgb(44, 40, 66);
	var _colBar = make_color_rgb(34, 30, 52);
	// solid 2px edge drawn over the fill, the old outline left a see-through gap when the gui is scaled
	var _frame = function(_x1, _y1, _x2, _y2)
	{
		draw_rectangle(_x1 - 1, _y1 - 1, _x2 + 1, _y1 + 1, false);
		draw_rectangle(_x1 - 1, _y2 - 1, _x2 + 1, _y2 + 1, false);
		draw_rectangle(_x1 - 1, _y1 - 1, _x1 + 1, _y2 + 1, false);
		draw_rectangle(_x2 - 1, _y1 - 1, _x2 + 1, _y2 + 1, false);
	};

	var _prevFont = draw_get_font();
	draw_set_font(ModList_Font());
	draw_set_valign(fa_middle);
	draw_set_halign(fa_left);

	var _hov = (_mx >= _X && _mx <= _X + _W && _my >= _Y && _my <= _Y + _HH);
	// solid, so the moving menu background doesn't show through
	draw_set_alpha(1);
	draw_set_color(_hov ? make_color_rgb(60, 52, 90) : _colBar);
	draw_rectangle(_X, _Y, _X + _W, _Y + _HH, false);
	draw_set_alpha(1);
	draw_set_color(c_black);
	_frame(_X, _Y, _X + _W, _Y + _HH);
	var _title = (_m.mlOpen ? "v" : ">") + "  " + ModList_Text("MODS") + " (" + string(array_length(_m.mlNames)) + ")";
	draw_set_color(c_yellow);
	draw_text_transformed(_X + 10, _Y + _HH * 0.5, _title, 0.6, 0.6, 0);
	draw_set_color(make_color_rgb(170, 160, 200));
	draw_text_transformed(_X + 22 + string_width(_title) * 0.6, _Y + _HH * 0.5 + 2, "v@VERSION@", 0.32, 0.32, 0);
	if (_m.mlOpen)
	{
		var _sh = (_mx >= _X + _W - 96 && _mx <= _X + _W - 6 && _my >= _Y + 4 && _my <= _Y + _HH - 4);
		draw_set_color(_sh ? _colHi : _colBg);
		draw_rectangle(_X + _W - 96, _Y + 5, _X + _W - 6, _Y + _HH - 5, false);
		draw_set_halign(fa_center);
		draw_set_color(c_white);
		draw_text_transformed(_X + _W - 51, _Y + _HH * 0.5, (_m.mlSort == 1) ? ModList_Text("Sort: Newest") : ModList_Text("Sort: A-Z"), 0.34, 0.34, 0);
		draw_set_halign(fa_left);
	}

	var _bottom = _Y + _HH;
	if (_m.mlOpen)
	{
		var _nf = array_length(_m.mlFolders);
		var _custom = _m.mlSec >= 1 && _m.mlSec - 1 < _nf;

		draw_set_alpha(1);
		draw_set_color(_colBar);
		draw_rectangle(_X, _SBY, _X + _W, _SBY + _SBH, false);
		draw_set_alpha(1);
		draw_set_color(c_black);
		_frame(_X, _SBY, _X + _W, _SBY + _SBH);

		var _secName = ModList_Text("All Mods");
		if (_custom)
		{
			_secName = _m.mlFolders[_m.mlSec - 1].name;
		}
		var _secText = _secName + "  (" + string(array_length(_m.mlView)) + ")";
		if (_m.mlEdit == "folder")
		{
			_secText = _m.mlEditText + _caret;
		}
		else if (_custom && _m.mlFolderEdit)
		{
			_secText = _secName + ModList_Text("  - pick mods");
		}

		var _sbMid = _SBY + _SBH * 0.5;
		draw_set_halign(fa_center);
		draw_set_color((_mx <= _X + 24 && _my >= _SBY && _my <= _SBY + _SBH) ? c_yellow : c_white);
		draw_text_transformed(_X + 12, _sbMid, "<", 0.5, 0.5, 0);
		draw_set_color((_mx >= _X + _W - 198 && _mx <= _X + _W - 176 && _my >= _SBY && _my <= _SBY + _SBH) ? c_yellow : c_white);
		draw_text_transformed(_X + _W - 187, _sbMid, ">", 0.5, 0.5, 0);

		if (_m.mlEdit == "folder")
		{
			draw_set_color(c_black);
			draw_rectangle(_X + 28, _SBY + 3, _X + _W - 202, _SBY + _SBH - 3, false);
			draw_set_color(c_white);
			draw_rectangle(_X + 28, _SBY + 3, _X + _W - 202, _SBY + _SBH - 3, true);
		}
		gpu_set_scissor(_X + 26, _SBY, _W - 226, _SBH);
		draw_set_color(_m.mlSec >= 1 ? make_color_rgb(255, 220, 140) : c_white);
		draw_text_transformed(_X + 26 + (_W - 226) * 0.5, _sbMid, _secText, 0.45, 0.45, 0);
		gpu_set_scissor(0, 0, _gw, _gh);

		var _btn = [ModList_Text("New"), "", "", ""];
		var _bx = [_X + _W - 124, _X + _W - 80, _X + _W - 36, _X + _W - 172];
		var _bw = [40, 40, 36, 44];
		var _bc = [c_white, c_white, make_color_rgb(240, 120, 120), c_white];
		if (_m.mlSec == 0)
		{
			_btn[1] = ModList_Text("All On");
			_btn[2] = ModList_Text("All Off");
			_bw[1] = 42;
			_bx[1] = _X + _W - 82;
			_bw[2] = 38;
			_bx[2] = _X + _W - 38;
			_bc[1] = make_color_rgb(120, 230, 120);
		}
		else if (_custom)
		{
			_btn[1] = _m.mlFolderEdit ? ModList_Text("Done") : ModList_Text("Edit");
			_btn[2] = (_m.mlDelArm > 0) ? ModList_Text("Sure?") : ModList_Text("Del");
			if (!_m.mlFolderEdit)
			{
				var _fon = false;
				var _fl = _m.mlFolders[_m.mlSec - 1].mods;
				for (var _fq = 0; _fq < array_length(_m.mlNames); _fq++)
				{
					for (var _fr = 0; _fr < array_length(_fl); _fr++)
					{
						if (_fl[_fr] == _m.mlNames[_fq] && _m.mlOn[_fq]) _fon = true;
					}
				}
				_btn[3] = _fon ? ModList_Text("All Off") : ModList_Text("All On");
				_bc[3] = _fon ? make_color_rgb(240, 120, 120) : make_color_rgb(120, 230, 120);
			}
		}
		for (var _b = 0; _b < 4; _b++)
		{
			if (_btn[_b] != "")
			{
				var _bh = (_mx >= _bx[_b] && _mx <= _bx[_b] + _bw[_b] && _my >= _SBY && _my <= _SBY + _SBH);
				draw_set_color(_bh ? _colHi : _colBg);
				draw_rectangle(_bx[_b] + 1, _SBY + 3, _bx[_b] + _bw[_b] - 2, _SBY + _SBH - 3, false);
				draw_set_color(_bc[_b]);
				draw_text_transformed(_bx[_b] + _bw[_b] * 0.5, _sbMid, _btn[_b], (string_length(_btn[_b]) > 5) ? 0.3 : 0.36, (string_length(_btn[_b]) > 5) ? 0.3 : 0.36, 0);
			}
		}
		draw_set_halign(fa_left);

		var _view = _m.mlView;
		for (var _r = 0; _r < _ROWS; _r++)
		{
			var _ry = _RY + _r * _RH;
			var _vp = _r + _m.mlScroll;
			var _rhov = (_mx >= _X && _mx <= _X + _W && _my >= _ry && _my <= _ry + _RH - 2);
			var _hasRow = _vp < array_length(_view);
			var _mi = _hasRow ? _view[_vp] : -1;

			draw_set_alpha(0.85);
			if (_hasRow && _m.mlFlash == _m.mlNames[_mi] && _m.mlFlashT > 0)
			{
				draw_set_color(make_color_rgb(90, 90, 40));
			}
			else
			{
				draw_set_color((_hasRow && _rhov) ? _colHi : _colBg);
			}
			draw_rectangle(_X, _ry, _X + _W, _ry + _RH - 2, false);
			draw_set_alpha(1);

			if (_hasRow)
			{
				var _on = _m.mlOn[_mi];
				var _base = _m.mlNames[_mi];
				var _mid = _ry + _RH * 0.5 - 1;

				var _armed = (_m.mlDelMod == _base && _m.mlDelModT > 0);
				if (_armed)
				{
					draw_set_alpha(0.85);
					draw_set_color(make_color_rgb(90, 30, 30));
					draw_rectangle(_X, _ry, _X + _W, _ry + _RH - 2, false);
					draw_set_alpha(1);
				}
				draw_set_color(_on ? make_color_rgb(40, 170, 70) : make_color_rgb(150, 45, 45));
				draw_rectangle(_X + 8, _ry + 5, _X + 48, _ry + _RH - 7, false);
				draw_set_halign(fa_center);
				draw_set_color(c_white);
				draw_text_transformed(_X + 28, _mid, _on ? ModList_Text("ON") : ModList_Text("OFF"), 0.38, 0.38, 0);
				draw_set_halign(fa_left);

				var _label = (_mi < array_length(_m.mlLabels)) ? _m.mlLabels[_mi] : _base;
				if (_m.mlEdit == "alias" && _m.mlEditKey == _base)
				{
					draw_set_color(c_black);
					draw_rectangle(_X + 54, _ry + 3, _X + _W - 74, _ry + _RH - 5, false);
					draw_set_color(c_white);
					draw_rectangle(_X + 54, _ry + 3, _X + _W - 74, _ry + _RH - 5, true);
					_label = _m.mlEditText + _caret;
				}
				if (_armed)
				{
					_label = ModList_Text("Click X again to remove from list");
				}
				gpu_set_scissor(_X + 56, _ry, _W - 132, _RH);
				draw_set_color(_armed ? make_color_rgb(255, 150, 150) : (_on ? c_white : c_gray));
				draw_text_transformed(_X + 58, _mid, _label, 0.45, 0.45, 0);
				gpu_set_scissor(0, 0, _gw, _gh);

				if (_custom && !_m.mlFolderEdit)
				{
					var _xh = (_mx >= _X + _W - 70 && _mx < _X + _W - 38 && _my >= _ry && _my <= _ry + _RH - 2);
					draw_set_color((_xh || _armed) ? make_color_rgb(150, 45, 45) : _colBar);
					draw_rectangle(_X + _W - 68, _ry + 4, _X + _W - 42, _ry + _RH - 6, false);
					draw_set_halign(fa_center);
					draw_set_color(make_color_rgb(240, 120, 120));
					draw_text_transformed(_X + _W - 55, _mid, "X", 0.4, 0.4, 0);
					draw_set_halign(fa_left);
				}
				var _icon = "";
				var _iconCol = c_white;
				if (_m.mlSec == 0)
				{
					_icon = "+";
					_iconCol = make_color_rgb(140, 220, 255);
				}
				else if (_custom && _m.mlFolderEdit)
				{
					var _inF = false;
					var _fm = _m.mlFolders[_m.mlSec - 1].mods;
					for (var _q = 0; _q < array_length(_fm); _q++)
					{
						if (_fm[_q] == _base)
						{
							_inF = true;
						}
					}
					_icon = _inF ? "-" : "+";
					_iconCol = _inF ? make_color_rgb(240, 120, 120) : make_color_rgb(120, 230, 120);
				}
				if (_icon != "")
				{
					var _ih = (_mx >= _X + _W - 36 && _mx <= _X + _W - 6 && _my >= _ry && _my <= _ry + _RH - 2);
					draw_set_color(_ih ? _colHi : _colBar);
					draw_rectangle(_X + _W - 34, _ry + 4, _X + _W - 8, _ry + _RH - 6, false);
					draw_set_halign(fa_center);
					draw_set_color(_iconCol);
					draw_text_transformed(_X + _W - 21, _mid, _icon, 0.5, 0.5, 0);
					draw_set_halign(fa_left);
				}
			}
		}

		var _total = array_length(_view);
		if (_total > _ROWS)
		{
			var _trackH = _ROWS * _RH - 2;
			var _thumbH = max(16, _trackH * _ROWS / _total);
			var _thumbY = _RY + (_trackH - _thumbH) * (_m.mlScroll / (_total - _ROWS));
			draw_set_color(c_black);
			draw_rectangle(_X + _W - 6, _RY, _X + _W - 1, _RY + _trackH, false);
			var _sbHot = _m.mlSbDrag || (_mx >= _X + _W - 8 && _mx <= _X + _W + 6 && _my >= _RY && _my <= _RY + _trackH);
			draw_set_color(_sbHot ? make_color_rgb(200, 190, 240) : make_color_rgb(150, 140, 190));
			draw_rectangle(_X + _W - 6, _thumbY, _X + _W - 1, _thumbY + _thumbH, false);
		}
		else if (_total == 0)
		{
			draw_set_halign(fa_center);
			draw_set_color(c_gray);
			var _empty = ModList_Text("No mods here");
			if (_custom)
			{
				_empty = ModList_Text("Empty folder - press Edit to add mods");
			}
			draw_text_transformed(_X + _W * 0.5, _RY + _RH * 0.5 - 1, _empty, 0.4, 0.4, 0);
			draw_set_halign(fa_left);
		}

		draw_set_alpha(1);
		draw_set_color(_colBar);
		draw_rectangle(_X, _FY, _X + _W, _FY + _FH, false);
		draw_set_color(c_black);
		_frame(_X, _FY, _X + _W, _FY + _FH);
		draw_set_halign(fa_center);
		draw_set_color(make_color_rgb(150, 145, 175));
		draw_text_transformed(_X + _W * 0.5, _FY + _FH * 0.5, ModList_Text("Shift + F1 - Copy debug txt"), 0.34, 0.34, 0);
		draw_set_halign(fa_left);
		_bottom = _FY + _FH;

		if (_m.mlPop >= 0 && _m.mlPop < array_length(_m.mlNames))
		{
			var _px = (_X + _W + 182 > _gw) ? _X - 176 : _X + _W + 6;
			var _pw = 170;
			var _ph = 22;
			var _pmod = _m.mlNames[_m.mlPop];
			if (_nf == 0)
			{
				draw_set_color(c_black);
				draw_rectangle(_px - 1, _m.mlPopY - 1, _px + _pw + 1, _m.mlPopY + _ph + 1, false);
				draw_set_color(_colBg);
				draw_rectangle(_px, _m.mlPopY, _px + _pw, _m.mlPopY + _ph, false);
				draw_set_color(c_gray);
				draw_text_transformed(_px + 8, _m.mlPopY + _ph * 0.5, ModList_Text("No folders yet - press New"), 0.34, 0.34, 0);
			}
			else
			{
				draw_set_color(c_black);
				draw_rectangle(_px - 1, _m.mlPopY - 1, _px + _pw + 1, _m.mlPopY + _nf * _ph + 1, false);
				for (var _p = 0; _p < _nf; _p++)
				{
					var _py = _m.mlPopY + _p * _ph;
					var _phov = (_mx >= _px && _mx <= _px + _pw && _my >= _py && _my < _py + _ph);
					draw_set_color(_phov ? _colHi : _colBg);
					draw_rectangle(_px, _py, _px + _pw, _py + _ph - 1, false);
					var _inP = false;
					var _pm = _m.mlFolders[_p].mods;
					for (var _pq = 0; _pq < array_length(_pm); _pq++)
					{
						if (_pm[_pq] == _pmod)
						{
							_inP = true;
						}
					}
					draw_set_color(_inP ? make_color_rgb(120, 230, 120) : c_gray);
					draw_text_transformed(_px + 8, _py + _ph * 0.5, _inP ? "[x]" : "[ ]", 0.38, 0.38, 0);
					gpu_set_scissor(_px + 30, _py, _pw - 34, _ph);
					draw_set_color(c_white);
					draw_text_transformed(_px + 32, _py + _ph * 0.5, _m.mlFolders[_p].name, 0.38, 0.38, 0);
					gpu_set_scissor(0, 0, _gw, _gh);
				}
			}
		}
	}

	if (_m.mlMsgT > 0)
	{
		_m.mlMsgT -= 1;
		draw_set_color(c_black);
		for (var _oa = 0; _oa < 8; _oa++)
		{
			draw_text_transformed(_X + lengthdir_x(1.5, _oa * 45), _bottom + 14 + lengthdir_y(1.5, _oa * 45), ModList_Message(_m.mlMsg), 0.45, 0.45, 0);
		}
		draw_set_color(make_color_hsv(floor(_m.mlFrame * 1.42) mod 256, 170, 255));
		draw_text_transformed(_X, _bottom + 14, ModList_Message(_m.mlMsg), 0.45, 0.45, 0);
		_bottom += 24;
	}
	if (_m.mlErr != "")
	{
		draw_set_color(c_red);
		draw_text_transformed(_X, _bottom + 14, ModList_Message(_m.mlErr), 0.4, 0.4, 0);
		_bottom += 24;
	}
	if (_m.mlNote != "")
	{
		draw_set_color(c_orange);
		draw_text_transformed(_X, _bottom + 14, ModList_Message(_m.mlNote), 0.4, 0.4, 0);
		_bottom += 24;
	}
	if (_m.mlDebugT > 0)
	{
		_m.mlDebugT -= 1;
		draw_set_color(c_black);
		for (var _ob = 0; _ob < 8; _ob++)
		{
			draw_text_transformed(_X + lengthdir_x(1.5, _ob * 45), _bottom + 14 + lengthdir_y(1.5, _ob * 45), ModList_Text("Copied debug to clipboard"), 0.45, 0.45, 0);
		}
		draw_set_color(make_color_hsv(floor(_m.mlFrame * 1.42) mod 256, 170, 255));
		draw_text_transformed(_X, _bottom + 14, ModList_Text("Copied debug to clipboard"), 0.45, 0.45, 0);
	}

	// scroll bar for the game's mod warning window. the window is centred and scaled
	// from a 640x360 layout, so the list sits at the same spot every time
	if (is_array(_m.mlPopBar))
	{
		var _sb = min(_gw / 640, _gh / 360);
		var _pbx = _gw * 0.5 + 111 * _sb;
		var _pby0 = _gh * 0.5 - 38.7 * _sb;
		var _pby1 = _gh * 0.5 + 52.7 * _sb;
		var _bww = 3 * _sb;
		var _bn2 = _m.mlPopBar[1];
		var _bv = _m.mlPopBar[2];
		var _bth = max(6 * _sb, (_pby1 - _pby0) * _bv / _bn2);
		var _bty = _pby0 + (_pby1 - _pby0 - _bth) * (_m.mlPopBar[0] / max(1, _bn2 - _bv));
		draw_set_alpha(1);
		draw_set_color(make_color_rgb(24, 18, 44));
		draw_rectangle(_pbx, _pby0, _pbx + _bww, _pby1, false);
		draw_set_color(make_color_rgb(150, 140, 190));
		draw_rectangle(_pbx, _bty, _pbx + _bww, _bty + _bth, false);
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_font(_prevFont);
});
