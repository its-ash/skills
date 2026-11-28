@REF:d3-visualization
§WHEN{custom_visual_encodings/layouts|complex_pan/zoom/brush|network/graph/hierarchy/tree/chord|geo_custom_projections|choreographed_transitions|pub_quality_styling|novel_charts|3D⇒Three.js}
§SETUP{ESM(`d3@7.9+`,ESM-only):`import * as d3 from 'd3';`∨tree-shake(`import{scaleLinear}from'd3-scale';import{max}from'd3-array';`)|CDN:`<script src="https://d3js.org/d3.v7.min.js"></script>`}

§INT{
  A_direct_DOM(complex_interactions/transitions):`if(!data||!data.length)return;const svg=d3.select('#chart');svg.selectAll('*').remove();`→scales/axes/els;
  B_declarative(simpler_charts/fw_render):D3_scales/coords(`scaleLinear().domain([0,d3.max(data,d=>d.value)]).range([0,400])`)→return_geometry_objects
}

§STRUCT{
  `if(!data||!data.length)return;const svg=d3.select('#chart');svg.selectAll('*').remove();`
  `w=800,h=400,m={top:20,right:30,bottom:40,left:50},iw=w-m.left-m.right,ih=h-m.top-m.bottom`;
  `g=svg.append('g').attr('transform',`translate(${m.left},${m.top})`)`;
  `x=d3.scaleLinear().domain([0,d3.max(data,d=>d.x)]).range([0,iw])`;`y=d3.scaleLinear().domain([0,d3.max(data,d=>d.y)]).range([ih,0])`;
  `g.append('g').attr('transform',`translate(0,${ih})`).call(d3.axisBottom(x))`;`g.append('g').call(d3.axisLeft(y))`;
  `g.selectAll('circle').data(data).join('circle').attr('cx',d=>x(d.x)).attr('cy',d=>y(d.y)).attr('r',5).attr('fill','steelblue')`
}

§RESP{
  win_resize:`window.addEventListener('resize',update)`w/`container.getBoundingClientRect()`→cleanup`()=>window.removeEventListener('resize',update)`;
  observer:`new ResizeObserver(()=>{const{width,height}=svgEl.getBoundingClientRect();d3.select(svgEl).attr('width',width).attr('height',height);drawChart(data,d3.select(svgEl),width,height);}).observe(svgEl.parentElement)`→cleanup`()=>observer.disconnect()`;
  debounce_handlers∧ensure_SVG_`width`/`height`∨`viewBox`
}

§PAT{
  bar:`x=d3.scaleBand().domain(data.map(d=>d.category)).range([0,iw]).padding(0.1)`;`rect`{`x:x(d.category)`,`y:y(d.value)`,`width:x.bandwidth()`,`height:ih-y(d.value)`};
  line:`d3.line().x(d=>x(d.date)).y(d=>y(d.value)).curve(d3.curveMonotoneX)`→`g.append('path').datum(data).attr('fill','none').attr('stroke','steelblue').attr('stroke-width',2).attr('d',line)`;
  scatter:`circle`{`cx:x(d.x)`,`cy:y(d.y)`,`r:sizeScale(d.size)`,`fill:colourScale(d.category)`,`opacity:0.7`};
  pie:`pie=d3.pie().value(d=>d.value).sort(null)`;`arc=d3.arc().innerRadius(0).outerRadius(Math.min(w,h)/2-20)`;`d3.scaleOrdinal(d3.schemeCategory10)`;`g`at`translate(${w/2},${h/2})`;`path.data(pie(data)).join('path').attr('d',arc).attr('stroke','white').attr('stroke-width',2)`;
  heatmap:`rows/cols=Array.from(new Set(...))`;`scaleBand().padding(0.01)`;`d3.scaleSequential(d3.interpolateYlOrRd).domain([0,d3.max(data,d=>d.value)])`;
  chord:`ir=Math.min(w,h)*0.3,or=ir+30`;symmetric`matrix[i][j]+=d.value;matrix[j][i]+=d.value`;`d3.chord().padAngle(0.05).sortSubgroups(d3.descending)`;`d3.arc().innerRadius(ir).outerRadius(or)`;`d3.ribbon().source(d=>d.source).target(d=>d.target)`;`fill-opacity:0.67`;`stroke:d3.rgb(c).darker()`;labels:`d.angle=(d.startAngle+d.endAngle)/2`,transform`rotate(${(d.angle*180/Math.PI)-90})translate(${or+30})${d.angle>Math.PI?'rotate(180)':''}`,`text-anchor:d.angle>Math.PI?'end':null`,`dy:'0.31em'`;
  force:`sim=d3.forceSimulation(nodes).force('link',d3.forceLink(links).id(d=>d.id).distance(100)).force('charge',d3.forceManyBody().strength(-300)).force('center',d3.forceCenter(w/2,h/2))`;drag`start`(`if(!e.active)sim.alphaTarget(0.3).restart();e.subject.fx=e.subject.x;e.subject.fy=e.subject.y`),`drag`(`fx=e.x;fy=e.y`),`end`(`if(!e.active)sim.alphaTarget(0);fx=null;fy=null`);`tick`updates`x1/y1/x2/y2`∧`cx/cy`
}

§INTERACT{
  tooltip:`div.tooltip`{`position:absolute;visibility:hidden;pointer-events:none;background-color:white;border:1px solid #ddd;padding:10px;border-radius:4px`}→`mouseover`(`opacity:1`,show,`html`)|`mousemove`(`top:event.pageY-10+'px'`,`left:event.pageX+10+'px'`)|`mouseout`(`opacity:0.7`,hide);
  zoom:`const zoom=d3.zoom().scaleExtent([0.5,10]).on('zoom',e=>g.attr('transform',e.transform));svg.call(zoom);`;
  click:`d3.selectAll('circle').attr('fill','steelblue');d3.select(this).attr('fill','orange');`
}

§TRANS{
  basic:`.transition().duration(750).attr(...)`;
  chain:`.transition().duration(500).attr(...).transition().duration(500).attr(...)`;
  stagger:`.transition().delay((d,i)=>i*50).duration(500).attr(...)`;
  ease:`.transition().duration(1000).ease(d3.easeBounceOut).attr(...)`
}

§SCALES{
  quant:`scaleLinear().domain([0,100]).range([0,500])`|`scaleLog().domain([1,1000])`|`scalePow().exponent(2)`|`scaleTime().domain([new Date(2024,0,1),new Date(2026,0,1)])`;
  ord:`scaleBand().domain([...]).range([0,400]).padding(0.1)`|`scalePoint()`|`scaleOrdinal(d3.schemeCategory10)`;
  seq_div:`scaleSequential(d3.interpolateBlues).domain([0,100])`|`scaleDiverging(d3.interpolateRdBu).domain([-10,0,10])`
}

§R{
  prep:filter`d.value!=null&&!isNaN(d.value)`,sort`data.toSorted((a,b)=>b.value-a.value)`,parse`d3.timeParse('%Y-%m-%d')(d.date)`;
  perf:DOM>1000⇒canvas|quadtree_collision|simplify`d3.line().curve(d3.curveStep)`|virtual_scroll|`requestAnimationFrame`|debounce_resize|`.join()`(¬enter/update/exit)|¬unnecessary_rerenders;
  a11y:`svg.attr('role','img').attr('aria-label','...')`+`<title>`/`<desc>`+contrast+keyboard_nav+data_table_alt;
  style:palette(`{primary:'#4A90E2',secondary:'#7B68EE',background:'#F5F7FA',text:'#333333',gridLines:'#E0E0E0'}`)+`font-family:'Inter, sans-serif';font-size:'12px'`+`.tick line`{`stroke:gridLines`,`stroke-dasharray:'2,2'`};
  binding:key`.data(data,d=>d.id)`∧validate_domains_for_NaN
}

§DEBUG{
  no_axes⇒NaN_domains,axis_group,transform_translate;
  no_transition⇒`.transition()`_before_attrs,unique_keys,data_deps;
  no_resize⇒ResizeObserver/listener,update_dims,SVG_`width`/`height`/`viewBox`;
  slow⇒limit_DOM(>1000→canvas),debounce_resize,`.join()`,avoid_rerenders
}

§CHK{clean_data→clear_SVG→margins+inner_dims→scales+axes→`.join()`→responsive→tooltip/zoom/click→transitions+durations→a11y+contrast→test(empty∧large)}

§REL{[frontend-development](../SKILL.md)|[javascript](../../typescript/references/javascript.md)|[typescript](../../typescript/SKILL.md)}
