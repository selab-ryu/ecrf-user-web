// 즉시 실행 함수(IIFE)로 전역 오염 방지
(() => {
	let jointNum = 0;
	const jointNumLabel = document.getElementById('jointNumLabel');
	const selectedButtonsLabel = document.getElementById('selectedButtonsLabel');
	const historyContainer = document.getElementById('historyContainer');
	//const patientImage = document.getElementById('patientImage');
	const imageWrapper = document.getElementById('imageWrapper');
	
	// tooltip 관련 변수
	let timeoutId;
	const tooltip = document.getElementById('tooltipContainer');
	
	//치식 이미지 크기 조정
	const initialWidth = imageWrapper.getBoundingClientRect().width;
	let currentScale = 1;
	const natW = 1223;
	const natH = 772;
	
    // 드래그 관련 변수 초기화
    let isDragging = false;
    let dragStartX = 0;
    let dragStartY = 0;
    let selectionBox = null;
    
    // 우선순위 배열을 함수 정의 이전에 선언
    const statePriority     = ['C3','C2','C1','W','Y','B','E','D'];
    const treatmentPriority = ['Ext','Pulpec','Pulpo','Apexo','Apexi','RCT','ZR','SS','RF','AF','GI','Seal'];
	
    // row별 속성 정의 (row: 1~4 영구치, 5~8 유치)
    const rowDefs = [
    	{ row: 1, xStart: 590, direction: -1, y1:  90,  y2: 148 },  
    	{ row: 2, xStart: 626, direction:  1, y1:  90,  y2: 148 }, 
    	{ row: 3, xStart: 626, direction:  1, y1: 620,  y2: 678 },  
    	{ row: 4, xStart: 590, direction: -1, y1: 620,  y2: 678 },  
    	{ row: 5, xStart: 590, direction: -1, y1: 266,  y2: 324 },  
    	{ row: 6, xStart: 626, direction:  1, y1: 266,  y2: 324 },  
    	{ row: 7, xStart: 626, direction:  1, y1: 442,  y2: 500 },  
    	{ row: 8, xStart: 590, direction: -1, y1: 442,  y2: 500 }, 
    ];

    const regionWidth = 67;  // 원본 코드에서 x2-x1 이 155px 로 일정
    const regions = rowDefs.flatMap(def => {
      const count = def.row <= 4 ? 8 : 5;  // 영구치는 8개, 유치는 5개
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

    console.log(regions);
  
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
    
    //좌클릭시 치식을 활성화 또는 비황성화 하는 function
    function handleRegionClick(e, region) { //좌클릭
        e.stopPropagation();
        const num = parseInt(region.name.replace('Teeth', ''), 10);
        if (num > 40) {
            const deciduousName = `Teeth${num - 40}`;
            const deciduousRegion = regions.find(r => r.name === deciduousName);
            if (deciduousRegion && deciduousRegion.history.length > 0) {
                console.log(`${deciduousName}에 이력이 있어 ${region.name} 클릭을 막습니다.`);
                return;
            }
        }
        region.isClicked = !region.isClicked;
        jointNum += region.isClicked ? 1 : -1;
        drawRegions();
    }

    //호버링 할경우 치식 기록을 보여주는 function
    function handleRegionMouseEnter(e, region) { //호버링 진입
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

    //호버링된 채로 마우스를 이동했을 경우 행동하는 function
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

    //호버링 종료시 행동하는 function
    function handleRegionMouseLeave() { //호버링 종료
        clearTimeout(timeoutId);
        document.getElementById('tooltipContainer').style.display = 'none';
    }

    //드래그 시작시 좌표 기록하는 function
    function handleWrapperMouseDown(e) { //드래그 시작
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

    //드래그 유지할 때 실행되는 function
    function handleWindowMouseMove(e) { //드래그 중
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

    function handleWindowMouseUp(e) { //드래그 종료
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
                if (num > 40) {
                    const deciduousName = `Teeth${num - 40}`;
                    const deciduousRegion = regions.find(r => r.name === deciduousName);
                    if (deciduousRegion && deciduousRegion.history.length > 0) {
                        console.log(`${deciduousName}에 이력이 있어 ${region.name} 토글을 건너뜁니다.`);
                        return;
                    }
                }
                region.isClicked = !region.isClicked;
                jointNum += region.isClicked ? 1 : -1;
            }
        });
        drawRegions();
    }
    
    //스크롤을 통한 이미지 zoom하는 function
    function imageWrapperWheel(e) { //이미지 Zoom 기능
        if (e.ctrlKey) {
      	  e.preventDefault();
      	  currentScale += -e.deltaY * 0.001;
      	  currentScale = Math.min(Math.max(currentScale, 0.5), 3);
      	  imageWrapper.style.maxWidth = 'none';
      	  imageWrapper.style.width = `${initialWidth * currentScale}px`;
      	  drawRegions();
      	  console.log(imageWrapper.style.width);
        }
    }
    
  //이미지 생성하는 function
    function drawRegions() { //이미지 생성
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

    //치식 번호 위에 사각형 영역 맞춰서 업데이트 하는 function
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

 // 이미지 위의 모든 숫자, 상태, 이력 라벨을 제거하는 function
    function clearLabels() {
        imageWrapper.querySelectorAll('.number-label, .state-label, .history-label').forEach(el => el.remove());
    }
 // 최신 이력 중에서 우선순위가 높은 상태(state)와 치료(treatment)를 가져오는  function
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
    // 치아 영역의 상태와 치료에 따라 배경색을 결정하는 function
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
    // 치아 번호, 상태, 치료 정보를 화면 상에 텍스트로 표시하는 function
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
            Object.assign(lbl.style, { left: `${left}px`, top: `${top - 30}px`, width: `${width}px`});
            lbl.textContent = stateMatch;
            imageWrapper.appendChild(lbl);
        }
        if (treatMatch) {
            const lbl = document.createElement('div');
            lbl.className = 'history-label';
            Object.assign(lbl.style, { left: `${left}px`, top: `${top + height + 2}px`, width: `${width}px`});
            lbl.textContent = treatMatch;
            imageWrapper.appendChild(lbl);
        }
    }
    // 선택된 치아 이력을 리스트로 표시하고, 선택 치아를 서버에 저장하는 function
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

