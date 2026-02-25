//functions

//좌클릭시 치식을 활성화 또는 비황성화 하는 function
function handleRegionClick(e, region) {
	//좌클릭
	e.stopPropagation();
	const regions = window.teeth.regions;

	const num = parseInt(region.name.replace('Teeth', ''), 10);
	if (num > 40) {
		const deciduousName = `Teeth${num - 40}`;
		const deciduousRegion = regions.find((r) => r.name === deciduousName);
		if (deciduousRegion && deciduousRegion.history.length > 0) {
			console.log(
				`${deciduousName}에 이력이 있어 ${region.name} 클릭을 막습니다.`
			);
			return;
		}
	}
	region.isClicked = !region.isClicked;

	window.teeth.jointNum += region.isClicked ? 1 : -1;

	drawRegions();
}

//호버링 할경우 치식 기록을 보여주는 function
function handleRegionMouseEnter(e, region, tooltipResourceURL) {
	//호버링 진입
	window.teeth.timeoutId = setTimeout(() => {
		const base = tooltipResourceURL;
		let urlObj = new URL(base);
		const NAMESPACE = window.teeth.NAMESPACE;
		urlObj.searchParams.set(NAMESPACE + 'regionName', region.name);

		const tooltipContainer = document.getElementById('tooltipContainer');
		setHistoryList(region, window.teeth.initHistory);

		tooltipContainer.style.display = 'block';
	}, 300);
}

function setHistoryList(region, historyList) {
	var data = [];

	historyList
		.filter((history) => history.region === region.name)
		.map((history, index) => {
			console.log(history);
			data.push({
				id: index,
				regionName: history.region,
				num: history.num,
				date: history.date,
				state: history.state,
				treatment: history.treatment,
			});
		});

	let theGrid = new wijmo.grid.FlexGrid('#tooltipContainer', {
		autoRowHeights: true,
		autoGenerateColumns: false,
		columns: [
			{ binding: 'date', header: 'Visit Date', width: '*' },
			{ binding: 'state', header: 'State', width: '*' },
			{ binding: 'treatment', header: 'Treatments', width: '*' },
		],
		loadedRows: function (s, e) {
			s.autoSizeColumns();
		},
		rowEditEnded: function (s, e) {
			s.autoSizeColumns();
		},
		allowResizing: 'None',
		itemsSource: data,
	});

	theGrid.autoSizeColumns();
	theGrid.noDataOverlayContent = 'No data available';
	theGrid.selectionMode = wijmo.asEnum(0, wijmo.grid.SelectionMode);

	window.teeth.historyGrid = theGrid;
}

//호버링된 채로 마우스를 이동했을 경우 행동하는 function
function handleRegionMouseMove(e) {
	//호버링 이동
	const imageWrapper = document.getElementById('imageWrapper');
	const rect = imageWrapper.getBoundingClientRect();

	// 마우스 커서의 좌표(이미지Wrapper 기준)
	const cursorX = e.clientX - rect.left;
	const cursorY = e.clientY - rect.top;

	const tooltip = document.getElementById('tooltipContainer');

	// 툴팁의 현재 렌더링된 높이를 가져옴 (px 단위)
	const tipHeight = tooltip.offsetHeight;

	// tooltip의 display 기준 정의
	const HEIGHT_THRESHOLD = 300;

	let left, top;

	// 툴팁 높이가 threshold 이상이면 우상단, 작으면 우하단
	if (tipHeight >= HEIGHT_THRESHOLD) {
		// 우상단: 커서 기준 오른쪽으로 10px, 위쪽으로 높이+10px
		left = cursorX + 10;
		top = cursorY - tipHeight - 10;
	} else {
		// 우하단: 커서 기준 오른쪽으로 10px, 아래쪽으로 10px
		left = cursorX + 10;
		top = cursorY + 10;
	}

	tooltip.style.left = `${left}px`;
	tooltip.style.top = `${top}px`;
}

//호버링 종료시 행동하는 function
function handleRegionMouseLeave() {
	//호버링 종료
	clearTimeout(window.teeth.timeoutId);
	const tooltipContainer = document.getElementById('tooltipContainer');
	tooltipContainer.style.display = 'none';
	tooltipContainer.innerHTML = '';

	const grid = window.teeth.historyGrid;
	if (grid) {
		grid.dispose();
	}
}

//드래그 시작시 좌표 기록하는 function
function handleWrapperMouseDown(e) {
	//드래그 시작
	const imageWrapper = document.getElementById('imageWrapper');
	if (e.target !== imageWrapper) return;
	e.preventDefault();
	window.teeth.isDragging = true;
	const rect = imageWrapper.getBoundingClientRect();
	window.teeth.dragStartX = e.clientX - rect.left;
	window.teeth.dragStartY = e.clientY - rect.top;
	window.teeth.selectionBox = document.createElement('div');
	window.teeth.selectionBox.classList.add('selection-box');

	imageWrapper.appendChild(window.teeth.selectionBox);
}

//드래그 유지할 때 실행되는 function
function handleWindowMouseMove(e) {
	//드래그 중
	if (!window.teeth.isDragging || !window.teeth.selectionBox) return;
	const imageWrapper = document.getElementById('imageWrapper');
	const rect = imageWrapper.getBoundingClientRect();
	const x = e.clientX - rect.left;
	const y = e.clientY - rect.top;
	const left = Math.min(x, window.teeth.dragStartX);
	const top = Math.min(y, window.teeth.dragStartY);
	const width = Math.abs(x - window.teeth.dragStartX);
	const height = Math.abs(y - window.teeth.dragStartY);
	Object.assign(window.teeth.selectionBox.style, {
		left: `${left}px`,
		top: `${top}px`,
		width: `${width}px`,
		height: `${height}px`,
	});
}

function handleWindowMouseUp(e) {
	//드래그 종료
	if (!window.teeth.isDragging) return;
	window.teeth.isDragging = false;
	if (window.teeth.selectionBox) {
		window.teeth.selectionBox.remove();
		window.teeth.selectionBox = null;
	}
	const imageWrapper = document.getElementById('imageWrapper');
	const rect = imageWrapper.getBoundingClientRect();
	const endX = e.clientX - rect.left;
	const endY = e.clientY - rect.top;
	const selX = Math.min(endX, window.teeth.dragStartX);
	const selY = Math.min(endY, window.teeth.dragStartY);
	const selW = Math.abs(endX - window.teeth.dragStartX);
	const selH = Math.abs(endY - window.teeth.dragStartY);

	const regions = window.teeth.regions;

	regions.forEach((region) => {
		const div = imageWrapper.querySelector(
			`.region[data-name="${region.name}"]`
		);
		const left = parseFloat(div.style.left);
		const top = parseFloat(div.style.top);
		const w = parseFloat(div.style.width);
		const h = parseFloat(div.style.height);
		if (
			left + w >= selX &&
			left <= selX + selW &&
			top + h >= selY &&
			top <= selY + selH
		) {
			const num = parseInt(region.name.replace('Teeth', ''), 10);
			if (num > 40) {
				const deciduousName = `Teeth${num - 40}`;
				const deciduousRegion = regions.find(
					(r) => r.name === deciduousName
				);
				if (deciduousRegion && deciduousRegion.history.length > 0) {
					console.log(
						`${deciduousName}에 이력이 있어 ${region.name} 토글을 건너뜁니다.`
					);
					return;
				}
			}
			region.isClicked = !region.isClicked;
			window.teeth.jointNum += region.isClicked ? 1 : -1;
		}
	});
	drawRegions();
}

//스크롤을 통한 이미지 zoom하는 function
function imageWrapperWheel(e) {
	//이미지 Zoom 기능
	const imageWrapper = document.getElementById('imageWrapper');
	if (e.ctrlKey) {
		e.preventDefault();
		window.teeth.currentScale += -e.deltaY * 0.001;
		window.teeth.currentScale = Math.min(
			Math.max(window.teeth.currentScale, 0.5),
			3
		);
		imageWrapper.style.maxWidth = 'none';
		imageWrapper.style.width =
			window.teeth.initialWidth * window.teeth.currentScale + 'px';
		drawRegions();
		console.log(imageWrapper.style.width);
	}
}

//이미지 생성하는 function
function drawRegions() {
	//이미지 생성
	clearLabels();

	const regions = window.teeth.regions;

	regions.forEach((region) => {
		const { stateMatch, treatMatch } = findPriorityMatches(region.history);
		updateRegionStyle(region, stateMatch, treatMatch);
		renderLabels(region, stateMatch, treatMatch);
	});

	const jointNumLabel = document.getElementById('jointNumLabel');

	jointNumLabel.textContent = window.teeth.jointNum;

	const selectedButtonsLabel = document.getElementById(
		'selectedButtonsLabel'
	);
	selectedButtonsLabel.textContent = regions
		.filter((r) => r.isClicked)
		.map((r) => r.name)
		.join(', ');
	const NAMESPACE = window.teeth.NAMESPACE;
	$('#' + NAMESPACE + 'addBtn').prop('disabled', window.teeth.jointNum <= 0);
	//updateHistoryDisplay();
}

//치식 번호 위에 사각형 영역 맞춰서 업데이트 하는 function
function updateRegionStyle(region, stateMatch, treatMatch) {
	const imageWrapper = document.getElementById('imageWrapper');
	const { width: curW, height: curH } = imageWrapper.getBoundingClientRect();
	const natW = window.teeth.natW;
	const natH = window.teeth.natH;
	const scaleX = curW / natW;
	const scaleY = curH / natH;
	const div = imageWrapper.querySelector(
		`.region[data-name="${region.name}"]`
	);
	Object.assign(div.style, {
		position: 'absolute',
		left: `${region.x1 * scaleX}px`,
		top: `${region.y1 * scaleY}px`,
		width: `${(region.x2 - region.x1) * scaleX}px`,
		height: `${(region.y2 - region.y1) * scaleY}px`,
		background: determineBackground(region, stateMatch, treatMatch),
	});
}

// 이미지 위의 모든 숫자, 상태, 이력 라벨을 제거하는 function
function clearLabels() {
	const imageWrapper = document.getElementById('imageWrapper');
	imageWrapper
		.querySelectorAll('.number-label, .state-label, .history-label')
		.forEach((el) => el.remove());
}

// 최신 이력 중에서 우선순위가 높은 상태(state)와 치료(treatment)를 가져오는  function
function findPriorityMatches(histories) {
	let stateMatch = null;
	let treatMatch = null;
	const statePriority = window.teeth.statePriority;
	const treatmentPriority = window.teeth.treatmentPriority;

	if (histories.length > 0) {
		const times = histories.map((e) => new Date(e.date).getTime());
		const maxTime = Math.max(...times);
		const latest = histories.filter(
			(e) => new Date(e.date).getTime() === maxTime
		);
		const allStates = latest
			.flatMap((e) => (e.state || '').split(','))
			.map((s) => s.trim())
			.filter(Boolean);
		const allTreats = latest
			.flatMap((e) => (e.treatment || '').split(','))
			.map((t) => t.trim())
			.filter(Boolean);

		stateMatch =
			statePriority.find((code) => allStates.includes(code)) || null;
		treatMatch =
			treatmentPriority.find((code) => allTreats.includes(code)) || null;
	}
	return { stateMatch, treatMatch };
}

// 치아 영역의 상태와 치료에 따라 배경색을 결정하는 function
function determineBackground(region, stateMatch, treatMatch) {
	const hasHistory = region.history && region.history.length > 0;
	const treatmentPriority = window.teeth.treatmentPriority;
	if (region.isClicked) return 'red';
	if (
		(!stateMatch || ['C3', 'C2', 'C1'].includes(stateMatch)) &&
		!treatMatch &&
		hasHistory
	) {
		return 'green';
	}
	let stateColor = 'white';
	let treatColor = 'white';
	if (['W', 'Y', 'B', 'E', 'D'].includes(stateMatch)) {
		stateColor = 'rgba(255, 165, 0, 0.6)';
	}
	if (treatmentPriority.includes(treatMatch)) {
		treatColor = 'rgba(0, 0, 255, 0.6)';
	}
	if (stateMatch && !treatMatch) {
		if (['C3', 'C2', 'C1'].includes(stateMatch)) stateColor = 'green';
		treatColor = stateColor;
	} else if (
		(!stateMatch && treatMatch) ||
		['C3', 'C2', 'C1'].includes(stateMatch)
	) {
		stateColor = treatColor;
	}
	return `linear-gradient(to bottom, ${stateColor} 0%, ${stateColor} 50%, ${treatColor} 50%, ${treatColor} 100%)`
		.replace(/\s+/g, ' ')
		.trim();
}

// 치아 번호, 상태, 치료 정보를 화면 상에 텍스트로 표시하는 function
function renderLabels(region, stateMatch, treatMatch) {
	const imageWrapper = document.getElementById('imageWrapper');
	const { width: curW, height: curH } = imageWrapper.getBoundingClientRect();
	const natW = window.teeth.natW;
	const natH = window.teeth.natH;
	const scaleX = curW / natW;
	const scaleY = curH / natH;
	const left = region.x1 * scaleX;
	const top = region.y1 * scaleY;
	const width = (region.x2 - region.x1) * scaleX;
	const height = (region.y2 - region.y1) * scaleY;

	const regionNum = region.name.replace('Teeth', '');
	const numLbl = document.createElement('div');
	numLbl.className = 'number-label';
	Object.assign(numLbl.style, {
		left: `${left}px`,
		top: `${top}px`,
		width: `${width}px`,
		height: `${height}px`,
	});
	numLbl.textContent = regionNum;
	imageWrapper.appendChild(numLbl);

	if (stateMatch) {
		const lbl = document.createElement('div');
		lbl.className = 'state-label';
		Object.assign(lbl.style, {
			left: `${left}px`,
			top: `${top - 30}px`,
			width: `${width}px`,
		});
		lbl.textContent = stateMatch;
		imageWrapper.appendChild(lbl);
	}
	if (treatMatch) {
		const lbl = document.createElement('div');
		lbl.className = 'history-label';
		Object.assign(lbl.style, {
			left: `${left}px`,
			top: `${top + height + 2}px`,
			width: `${width}px`,
		});
		lbl.textContent = treatMatch;
		imageWrapper.appendChild(lbl);
	}
}

// 선택된 치아 이력을 리스트로 표시하고, 선택 치아를 서버에 저장하는 function
function updateHistoryDisplay() {
	const historyContainer = document.getElementById('historyContainer');

	historyContainer.innerHTML = '';
	const regions = window.teeth.regions;

	regions
		.filter((r) => r.history.length)
		.forEach((region) => {
			const header = document.createElement('h4');
			header.textContent = region.name;
			historyContainer.appendChild(header);
			const clickedNums = regions
				.filter((r) => r.isClicked)
				.map((r) => r.name.replace('Teeth', ''));

			$.ajax({
				type: 'POST',
				url: '/o/teeth-web/ajax/save_teeth_selection.jsp',
				data: { teeths: clickedNums.join(',') },
				success(resp) {
					console.log('저장 응답:', resp);
					const NAMESPACE = window.teeth.NAMESPACE;
					$('#' + NAMESPACE + 'teeths').val(clickedNums.join(','));
				},
				error(xhr, status, err) {
					console.error('저장 실패:', err);
				},
			});

			const ul = document.createElement('ul');
			region.history.forEach((e) => {
				const li = document.createElement('li');
				li.textContent = `${e.date} – ${e.treatment}`;
				ul.appendChild(li);
			});
			historyContainer.appendChild(ul);
		});
}

Liferay.provide(
	window,
	'openDialog',
	function (portletId, baseURL, crfId, subjectId, linkId) {
		var selectedTeeth = document.getElementById(
			'selectedButtonsLabel'
		).textContent;
		console.log('teeth val : ', selectedTeeth);

		var url = Liferay.Util.PortletURL.createRenderURL(baseURL, {
			p_p_id: portletId,
			p_auth: Liferay.authToken,
			p_p_state: 'pop_up',
			teeths: selectedTeeth,
			crfId: crfId,
			subjectId: subjectId,
			linkId: linkId,
			mvcRenderCommandName: '/render/add_tooth_treatment',
		});

		Liferay.Util.openWindow({
			dialog: {
				destroyOnClose: true,
				centered: true,
				modal: true,
				resizable: true,
				height: 950,
				width: 1200,
			},
			id: 'addTreatmentDialog',
			title: 'Add Treatement',
			uri: url.toString(),
		});
	},
	['liferay-portlet-url']
);

Liferay.provide(
	window,
	'closeDialog',
	function (dialogId) {
		var dialog = Liferay.Util.Window.getById(dialogId);
		dialog.destroy();
	},
	['aui-base']
);

Liferay.provide(
	window,
	'openHistoryModal',
	function (portletId, baseURL, regionName, crfId, subjectId, linkId) {
		var DisplayRegionName = regionName.replace(/(\D+)(\d+)/, '$1 $2');

		var url = Liferay.Util.PortletURL.createRenderURL(baseURL, {
			p_p_id: portletId,
			p_auth: Liferay.authToken,
			p_p_state: 'pop_up',
			regionName: regionName,
			subjectId: subjectId,
			crfId: crfId,
			linkId: linkId,
			mvcRenderCommandName: '/teeth/historyPopup',
		});

		const tooltip = document.getElementById('tooltipContainer');

		if (tooltip.style.display !== 'none') {
			tooltip.style.display = 'none';
		}

		Liferay.Util.openWindow({
			dialog: {
				destroyOnClose: true,
				centered: true,
				modal: true,
				resizable: false,
				height: 950,
				width: 1200,
			},
			id: 'treatmentListDialog',
			title: 'Treatment Record: ' + DisplayRegionName,
			uri: url,
		});
	},
	['liferay-portlet-url']
);

Liferay.provide(
	window,
	'onenViewAuditModal',
	function (portletId, baseURL, crfId, subjectId, linkId, mode) {
		var url = Liferay.Util.PortletURL.createRenderURL(baseURL, {
			p_p_id: portletId,
			p_auth: Liferay.authToken,
			p_p_state: 'pop_up',
			crfId: crfId,
			subjectId: subjectId,
			linkId: linkId,
			mode: mode,
			mvcRenderCommandName: '/teeth/viewAuditTrail',
		});

		Liferay.Util.openWindow({
			dialog: {
				destroyOnClose: true,
				centered: true,
				modal: true,
				resizable: true,
				height: 950,
				width: 1200,
			},
			id: 'viewAuditDialog',
			title: Liferay.Language.get(
				'ecrf-user.crf-data.teeth.button.viewFullAudit'
			),
			uri: url,
		});
	},
	['liferay-portlet-url']
);
