(() => {
	console.log('ready!');
	let jointNum = 0;
	const jointNumLabel = document.getElementById('jointNumLabel');
	const selectedButtonsLabel = document.getElementById('selectedButtonsLabel');
	const historyContainer = document.getElementById('historyContainer');
	const imageWrapper = document.getElementById('imageWrapper');
	
	// tooltip 관련 변수
	let timeoutId;
	const tooltip = document.getElementById('tooltipContainer');
	
	//치식 이미지 크기 조정
	const initialWidth = imageWrapper.getBoundingClientRect().width;
	let currentScale = 1;
	const natW = 2806;
	const natH = 834;
	
    // 드래그 관련 변수 초기화
    let isDragging = false;
    let dragStartX = 0;
    let dragStartY = 0;
    let selectionBox = null;
    
    // 우선순위 배열을 함수 정의 이전에 선언
    const statePriority     = ['C3','C2','C1','W','Y','B','E','D'];
    const treatmentPriority = ['Ext','Pulpec','Pulpo','Apexo','Apexi','RCT','ZR','SS','RF','AF','GI','Seal'];
    
    // row별 속성 정의 (row: 5~8 유치)
    const rowDefs = [
    	{ row: 5, xStart: 1358, direction: -1, y1:  150,  y2:  283 },  
    	{ row: 6, xStart: 1440, direction:  1, y1:  150,  y2:  283 },  
    	{ row: 7, xStart: 1440, direction:  1, y1:  557,  y2:  690 },  
    	{ row: 8, xStart: 1358, direction: -1, y1:  557,  y2:  690 },  
    ];
    
    const regionWidth = 155;  // 원본 코드에서 x2-x1 이 155px 로 일정
    const regions = rowDefs.flatMap(def => {
      const count = 5;  // 유치는 5개
      return Array.from({ length: count }, (_, idx) => {
        // raw 계산
        const rawX1 = def.xStart + idx * regionWidth * def.direction;
        const rawX2 = rawX1   + regionWidth * def.direction;
        // 항상 x1 < x2 로 정렬
        const x1 = Math.min(rawX1, rawX2);
        const x2 = Math.max(rawX1, rawX2);

        return {
          name:    `Teeth${def.row * 10 + (idx + 1)}`,
          x1, y1:  def.y1,
          x2, y2:  def.y2,
          isClicked: false,
          history:   []
        };
      });
    });
	
	  
    // JSP 에서 전달된 historyMap 을 전역으로 사용
    regions.forEach(r => {
        if (typeof historyMap === 'object' && historyMap) {
            r.history = historyMap[r.name] || [];
        }
    });

    // --- 이벤트 리스너 등록 ---
    regions.forEach(region => {
        const div = document.createElement('div');
        div.classList.add('region');
        div.dataset.name = region.name;
        div.addEventListener('click', e => handleRegionClick(e, region));
        div.addEventListener('mouseenter', e => handleRegionMouseEnter(e, region));
        div.addEventListener('mousemove', handleRegionMouseMove);
        div.addEventListener('mouseleave', handleRegionMouseLeave);
        imageWrapper.appendChild(div);
    });

    imageWrapper.addEventListener('mousedown', handleWrapperMouseDown);
    window.addEventListener('mousemove', handleWindowMouseMove);
    window.addEventListener('mouseup', handleWindowMouseUp);

    imageWrapper.addEventListener('wheel', imageWrapperWheel);
    
    imageWrapper.addEventListener('load', drawRegions);
    window.addEventListener('resize', drawRegions);

    drawRegions();
    
    
    
    // functions
    
    // 치아 영역을 클릭하면 해당 치아의 선택 상태를 토글하고 화면을 다시 그림
    function handleRegionClick(e, region) {
        e.stopPropagation();
        const num = parseInt(region.name.replace('Teeth', ''), 10);
        region.isClicked = !region.isClicked;
        jointNum += region.isClicked ? 1 : -1;
        drawRegions();
    }
    // 마우스가 치아 영역 위에 올라가면 300ms 후 AJAX로 툴팁 데이터를 요청해 표시
    function handleRegionMouseEnter(e, region) {
        timeoutId = setTimeout(() => {
            const base = tooltipResourceURL;
            let urlObj = new URL(base);
            urlObj.searchParams.set(NAMESPACE + 'regionName', region.name);
            $.ajax({
                type: 'POST',
                url: urlObj,
                dataType: 'html',
                data: { keyName: region.name },
                success(response) {
                    const container = document.getElementById('tooltipContainer');
                    container.innerHTML = response;
                    container.style.display = 'block';
                },
                error(xhr, status, error) {
                    console.error('AJAX 실패:', error);
                    const container = document.getElementById('tooltipContainer');
                    container.innerHTML = '툴팁 로드 실패';
                    container.style.display = 'block';
                }
            });
        }, 300);
    }
    // 툴팁이 표시 중일 때 마우스 위치에 따라 툴팁 위치를 동적으로 조정
    function handleRegionMouseMove(e) { //호버링 이동
        const rect = imageWrapper.getBoundingClientRect();

        // 마우스 커서의 좌표(이미지Wrapper 기준)
        const cursorX = e.clientX - rect.left;
        const cursorY = e.clientY - rect.top;

        // 툴팁의 현재 렌더링된 높이를 가져옴 (px 단위)
        const tipHeight = tooltip.offsetHeight;

        // tooltip의 display 기준 정의
        const HEIGHT_THRESHOLD = 300;

        let left, top;

        // 툴팁 높이가 threshold 이상이면 우상단, 작으면 우하단
        if (tipHeight >= HEIGHT_THRESHOLD) {
            // 우상단: 커서 기준 오른쪽으로 10px, 위쪽으로 높이+10px
            left = cursorX + 10;
            top  = cursorY - tipHeight - 10;
        } else {
            // 우하단: 커서 기준 오른쪽으로 10px, 아래쪽으로 10px
            left = cursorX + 10;
            top  = cursorY + 10;
        }

        tooltip.style.left = `${left}px`;
        tooltip.style.top  = `${top}px`;
    }
    // 마우스가 치아 영역을 벗어나면 툴팁 표시를 숨김
    function handleRegionMouseLeave() {
        clearTimeout(timeoutId);
        document.getElementById('tooltipContainer').style.display = 'none';
    }
    // 이미지 영역을 클릭하면 드래그 선택 시작 지점을 저장하고 선택 박스를 생성
    function handleWrapperMouseDown(e) {
        if (e.target !== imageWrapper) return;
        e.preventDefault();
        isDragging = true;
        const rect = imageWrapper.getBoundingClientRect();
        dragStartX = e.clientX - rect.left;
        dragStartY = e.clientY - rect.top;
        selectionBox = document.createElement('div');
        selectionBox.classList.add('selection-box');
        imageWrapper.appendChild(selectionBox);
    }
    // 드래그 중일 때 선택 박스의 크기와 위치를 마우스 움직임에 따라 조정
    function handleWindowMouseMove(e) {
        if (!isDragging || !selectionBox) return;
        const rect = imageWrapper.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        const left = Math.min(x, dragStartX);
        const top = Math.min(y, dragStartY);
        const width = Math.abs(x - dragStartX);
        const height = Math.abs(y - dragStartY);
        Object.assign(selectionBox.style, { left: `${left}px`, top: `${top}px`, width: `${width}px`, height: `${height}px` });
    }
    // 드래그 종료 시 선택 박스에 포함된 치아들을 선택/해제 상태로 토글하고 다시 그림
    function handleWindowMouseUp(e) {
        if (!isDragging) return;
        isDragging = false;
        if (selectionBox) {
            selectionBox.remove();
            selectionBox = null;
        }
        const rect = imageWrapper.getBoundingClientRect();
        const endX = e.clientX - rect.left;
        const endY = e.clientY - rect.top;
        const selX = Math.min(endX, dragStartX);
        const selY = Math.min(endY, dragStartY);
        const selW = Math.abs(endX - dragStartX);
        const selH = Math.abs(endY - dragStartY);
        regions.forEach(region => {
            const div = imageWrapper.querySelector(`.region[data-name="${region.name}"]`);
            const left = parseFloat(div.style.left);
            const top = parseFloat(div.style.top);
            const w = parseFloat(div.style.width);
            const h = parseFloat(div.style.height);
            if (left + w >= selX && left <= selX + selW && top + h >= selY && top <= selY + selH) {
                const num = parseInt(region.name.replace('Teeth', ''), 10);
                region.isClicked = !region.isClicked;
                jointNum += region.isClicked ? 1 : -1;
            }
        });
        drawRegions();
    }
    
    // Ctrl + 마우스 휠 조작으로 이미지 확대/축소 비율을 조정하고 다시 그림
    function imageWrapperWheel(e) {
        if (e.ctrlKey) {                                // Ctrl+휠 줌 감지 
      	  e.preventDefault();
      	  currentScale += -e.deltaY * 0.001;
      	  currentScale = Math.min(Math.max(currentScale, 0.5), 3);
      	  imageWrapper.style.maxWidth = 'none';
      	  imageWrapper.style.width = `${initialWidth * currentScale}px`;
      	  drawRegions();
        }
    }
    // 모든 치아 영역의 상태를 기반으로 스타일과 라벨을 렌더링하고, 선택 상태를 UI에 반영
    function drawRegions() {
        clearLabels();
        regions.forEach(region => {
            const { stateMatch, treatMatch } = findPriorityMatches(region.history);
            updateRegionStyle(region, stateMatch, treatMatch);
            renderLabels(region, stateMatch, treatMatch);
        });
        jointNumLabel.textContent = jointNum;
        selectedButtonsLabel.textContent = regions.filter(r => r.isClicked).map(r => r.name).join(', ');
        $('#' + NAMESPACE + 'addBtn').prop('disabled', jointNum <= 0);
        updateHistoryDisplay();
    }
    // 치아 영역의 크기, 위치, 배경색을 이미지 크기에 맞춰 계산해 스타일 적용
    function updateRegionStyle(region, stateMatch, treatMatch) {
    	const { width: curW, height: curH } = imageWrapper.getBoundingClientRect();
        const scaleX = curW / natW;
        const scaleY = curH / natH;
        const div = imageWrapper.querySelector(`.region[data-name="${region.name}"]`);
        Object.assign(div.style, {
            position: 'absolute',
            left: `${region.x1 * scaleX}px`,
            top:  `${region.y1 * scaleY}px`,
            width: `${(region.x2 - region.x1) * scaleX}px`,
            height: `${(region.y2 - region.y1) * scaleY}px`,
            background: determineBackground(region, stateMatch, treatMatch)
        });
    }
    // 이전에 표시된 모든 숫자/상태/이력 라벨을 제거
    function clearLabels() {
        imageWrapper.querySelectorAll('.number-label, .state-label, .history-label').forEach(el => el.remove());
    }
    // 가장 최근 이력 중 우선순위가 높은 상태/치료 코드를 추출
    function findPriorityMatches(histories) {
        let stateMatch = null;
        let treatMatch = null;
        if (histories.length > 0) {
            const times = histories.map(e => new Date(e.date).getTime());
            const maxTime = Math.max(...times);
            const latest = histories.filter(e => new Date(e.date).getTime() === maxTime);
            const allStates = latest.flatMap(e => (e.state || '').split(',')).map(s => s.trim()).filter(Boolean);
            const allTreats = latest.flatMap(e => (e.treatment || '').split(',')).map(t => t.trim()).filter(Boolean);
            stateMatch = statePriority.find(code => allStates.includes(code)) || null;
            treatMatch = treatmentPriority.find(code => allTreats.includes(code)) || null;
        }
        return { stateMatch, treatMatch };
    }
    // 가장 최근 이력 중 우선순위가 높은 상태/치료 코드를 추출
    function determineBackground(region, stateMatch, treatMatch) {
        const hasHistory = region.history && region.history.length > 0;
        if (region.isClicked) return 'red';
        if ((!stateMatch || ['C3','C2','C1'].includes(stateMatch)) && !treatMatch && hasHistory) {
            return 'green';
        }
        let stateColor = 'white';
        let treatColor = 'white';
        if (['W','Y','B','E','D'].includes(stateMatch)) {
            stateColor = 'rgba(255, 165, 0, 0.6)';
        }
        if (treatmentPriority.includes(treatMatch)) {
            treatColor = 'rgba(0, 0, 255, 0.6)';
        }
        if (stateMatch && !treatMatch) {
            if (['C3','C2','C1'].includes(stateMatch)) stateColor = 'green';
            treatColor = stateColor;
        } else if ((!stateMatch && treatMatch) || ['C3','C2','C1'].includes(stateMatch)) {
            stateColor = treatColor;
        }
        return `linear-gradient(to bottom, ${stateColor} 0%, ${stateColor} 50%, ${treatColor} 50%, ${treatColor} 100%)`.replace(/\s+/g, ' ').trim();
    }
    // 치아 번호, 상태 코드, 치료 코드 라벨을 해당 치아 영역에 렌더링
    function renderLabels(region, stateMatch, treatMatch) {
    	const { width: curW, height: curH } = imageWrapper.getBoundingClientRect();
        const scaleX = curW / natW;
        const scaleY = curH / natH;
        const left   = region.x1 * scaleX;
        const top    = region.y1 * scaleY;
        const width  = (region.x2 - region.x1) * scaleX;
        const height = (region.y2 - region.y1) * scaleY;
        
        const regionNum = region.name.replace('Teeth', '');
        const numLbl = document.createElement('div');
        numLbl.className = 'number-label';
        Object.assign(numLbl.style, {
            left:         `${left}px`,
            top:          `${top}px`,
            width:        `${width}px`,
            height:       `${height}px`
        });
        numLbl.textContent = regionNum;
        imageWrapper.appendChild(numLbl);
        
        if (stateMatch) {
            const lbl = document.createElement('div');
            lbl.className = 'state-label';
            Object.assign(lbl.style, { left: `${left}px`, top: `${top - 30}px`, width: `${width}px` });
            lbl.textContent = stateMatch;
            imageWrapper.appendChild(lbl);
        }
        if (treatMatch) {
            const lbl = document.createElement('div');
            lbl.className = 'history-label';
            Object.assign(lbl.style, { left: `${left}px`, top: `${top + height + 2}px`, width: `${width}px` });
            lbl.textContent = treatMatch;
            imageWrapper.appendChild(lbl);
        }
    }
    // 가장 최근 이력 중 우선순위가 높은 상태/치료 코드를 추출
    function updateHistoryDisplay() {
        historyContainer.innerHTML = '';
        regions.filter(r => r.history.length).forEach(region => {
            const header = document.createElement('h4');
            header.textContent = region.name;
            historyContainer.appendChild(header);
            const clickedNums = regions.filter(r => r.isClicked).map(r => r.name.replace('Teeth',''));
            $.ajax({
                type: 'POST',
                url: '/o/teeth-web/ajax/save_teeth_selection.jsp',
                data: { teeths: clickedNums.join(',') },
                success(resp) { console.log('저장 응답:', resp); $('#' + NAMESPACE + 'teeths').val(clickedNums.join(',')); },
                error(xhr, status, err) { console.error('저장 실패:', err); }
            });
            const ul = document.createElement('ul');
            region.history.forEach(e => {
                const li = document.createElement('li');
                li.textContent = `${e.date} – ${e.treatment}`;
                ul.appendChild(li);
            });
            historyContainer.appendChild(ul);
        });
    }
	
})();