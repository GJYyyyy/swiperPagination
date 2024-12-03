<template>
    <div class="web-page-swiper" :class="{ grab: mousedown }" :style="`--offset-y: ${pageOffsetY}px; --animation-duration: ${animationDuration}s; --page-transition: ${animation ? 'top' : 'none'
        };`" ref="pageContainer">
        <!-- 上一页预加载页面提示 -->
        <div class="prev-page-loading" :class="{ show: !pageNumModalVisible }">
            <div>下拉刷新</div>
        </div>

        <div class="current-page">
            <slot></slot>
        </div>

        <!-- 下一页预加载页面提示 -->
        <div class="next-page-loading" :class="{ show: !pageNumModalVisible }">
            <div>上拉刷新</div>
        </div>

        <div v-if="pageModal" class="modal" :class="{ show: pageNumModalVisible }"
            :style="`--page-modal-opacity: ${pageModalOpacity};`">
            {{ pageNum }}
        </div>
    </div>
</template>

<script>
/**
 * 判断屏幕是否是触摸屏
 * @returns
 */
export const isTouchScreen = () => {
    if ("ontouchstart" in window || navigator.maxTouchPoints > 0) return true;
    else return false;
};

const delay = (delayTime = 0) => {
    return new Promise((resolve) => {
        setTimeout(resolve, delayTime);
    });
};

export default {
    name: "swiper-pagination",
    props: {
        // 当前页码
        pageNum: {
            type: Number,
            default: 1,
        },
        // 当前页数据条数
        pageSize: {
            type: Number,
            default: 10,
        },
        // 总数据条数
        total: {
            type: Number,
            default: 20,
        },
        // 支持的翻页事件，可以随意组合
        events: {
            type: Array,
            default: () => ["wheel", "drag", "touch"], // wheel：表示支持WEB端鼠标滚轮翻页；move：表示支持WEB端鼠标拖动翻页；touch：表示支持触屏拖动翻页
        },
        // 翻页时是否展示页码遮罩
        pageModal: {
            type: Boolean,
            default: true,
        },
        // 页码遮罩透明度
        pageModalOpacity: {
            type: Number,
            default: 0.35,
        },
        // 动画持续时间，单位：秒
        animationDuration: {
            type: Number,
            default: 0.4,
        },
        // 触发加载上一页/下一页的容器移动高度极限，默认0.25表示当容器上下移动超过自身高度25%时触发
        triggerLimit: {
            type: Number,
            default: 0.25,
        },
        // 上一页/下一页出现的方式
        togglePageType: {
            type: String,
            default: "slide", // slide：滑动出现；instantly：瞬间出现；
        },
    },
    data: () => ({
        touchScreen: false,
        pageOffsetY: 0,
        animation: true,
        pageRollTimer: 0,
        pageRollInterval: 500,
        pageNumModalVisible: false,

        touchstartPageY: 0,
        mousedown: false,
    }),
    computed: {
        _pageNum: {
            get() {
                return this.pageNum;
            },
            set(newVal) {
                this.$emit("update:pageNum", newVal);
            },
        },
    },
    mounted() {
        this.touchScreen = isTouchScreen();
        this.initEvent();
    },

    beforeDestroy() {
        this.destroyEvent();
    },
    methods: {
        initEvent() {
            let pageContainer = this.$refs.pageContainer;

            // 触摸屏事件
            if (this.touchScreen) {
                if (this.events.includes("touch")) {
                    pageContainer.addEventListener(
                        "touchstart",
                        this.onPageContainerTouchstart
                    );
                    pageContainer.addEventListener(
                        "touchmove",
                        this.onPageContainerTouchmove
                    );
                    pageContainer.addEventListener(
                        "touchend",
                        this.onPageContainerTouchend
                    );
                }
            }

            // 非触摸屏事件
            else {
                if (this.events.includes("wheel")) {
                    pageContainer.addEventListener(
                        "mousewheel",
                        this.onPageContainerMousewheel
                    );
                }
                if (this.events.includes("drag")) {
                    pageContainer.addEventListener(
                        "mousedown",
                        this.onPageContainerMousedown
                    );
                    pageContainer.addEventListener(
                        "mousemove",
                        this.onPageContainerMousemove
                    );
                    pageContainer.addEventListener(
                        "mouseup",
                        this.onPageContainerMouseup
                    );
                }
            }
        },
        destroyEvent() {
            let pageContainer = this.$refs.pageContainer;

            // 触摸屏事件
            if (this.touchScreen) {
                if (this.events.includes("touch")) {
                    pageContainer.removeEventListener(
                        "touchstart",
                        this.onPageContainerTouchstart
                    );
                    pageContainer.removeEventListener(
                        "touchmove",
                        this.onPageContainerTouchmove
                    );
                    pageContainer.removeEventListener(
                        "touchend",
                        this.onPageContainerTouchend
                    );
                }
            }

            // 非触摸屏事件
            else {
                if (this.events.includes("wheel")) {
                    pageContainer.removeEventListener(
                        "mousewheel",
                        this.onPageContainerMousewheel
                    );
                }
                if (this.events.includes("drag")) {
                    pageContainer.removeEventListener(
                        "mousedown",
                        this.onPageContainerMousedown
                    );
                    pageContainer.removeEventListener(
                        "mousemove",
                        this.onPageContainerMousemove
                    );
                    pageContainer.removeEventListener(
                        "mouseup",
                        this.onPageContainerMouseup
                    );
                }
            }
        },
        onPageContainerTouchstart(ev) {
            this.animation = false;
            let { pageY } = ev.touches[0];
            this.touchstartPageY = pageY;
        },
        onPageContainerTouchmove(ev) {
            let { pageY } = ev.touches[0];
            let pageOffsetY = pageY - this.touchstartPageY;
            // 向上滚动
            if (pageOffsetY > 0) {
                // 首页无法再向上滚动
                if (this._pageNum <= 1) {
                    this.$emit("firstPage");
                    return;
                }
            }

            // 向下滚动
            else if (pageOffsetY < 0) {
                // 尾页无法再向下滚动
                if (this._pageNum * this.pageSize >= this.total) {
                    this.$emit("lastPage");
                    return;
                }
            }
            this.pageOffsetY = pageOffsetY;
        },
        onPageContainerTouchend(ev) {
            this.onContainerScroll();
        },
        onPageContainerMousewheel(ev) {
            let { deltaY } = ev;

            // 向上滚动
            if (deltaY < 0) {
                // 第一页无法再向上滚动
                if (this._pageNum <= 1) {
                    this.$emit("firstPage");
                    return;
                }
            }

            // 向下滚动
            else if (deltaY > 0) {
                // 最后一页无法再向下滚动
                if (this._pageNum * this.pageSize >= this.total) {
                    this.$emit("lastPage");
                    return;
                }
            }

            // 滚动方向与视觉效果是相反的，所以需要将值取反
            this.pageOffsetY -= deltaY;

            this.onContainerScroll();
        },
        onPageContainerMousedown(ev) {
            this.mousedown = true;
            this.animation = false;
            let { pageY } = ev;
            this.touchstartPageY = pageY;
        },
        onPageContainerMousemove(ev) {
            if (!this.mousedown) return;
            let { pageY } = ev;
            let pageOffsetY = pageY - this.touchstartPageY;
            // 向上滚动
            if (pageOffsetY > 0) {
                // 第一页无法再向上滚动
                if (this._pageNum <= 1) {
                    this.$emit("firstPage");
                    return;
                }
            }

            // 向下滚动
            else if (pageOffsetY < 0) {
                // 最后一页无法再向下滚动
                if (this._pageNum * this.pageSize >= this.total) {
                    this.$emit("lastPage");
                    return;
                }
            }
            this.pageOffsetY = pageOffsetY;
        },
        onPageContainerMouseup(ev) {
            this.mousedown = false;
            this.onContainerScroll();
        },
        /**
         * 核心方法，容器移动时判断是否到达翻页极限，如到达，执行翻页逻辑
         */
        async onContainerScroll() {
            let containerHeight = this.$refs.pageContainer.clientHeight;

            /*
            当滚动超过容器移动高度极限，则加载上一页/下一页，并且取消事件绑定（取消事件绑定主要是为了防抖，动画完成后会再次绑定事件）
            如果没有超过容器一般距离，则延迟后回到当前页
            */
            if (
                Math.abs(this.pageOffsetY) >
                containerHeight * this.triggerLimit
            ) {
                clearTimeout(this.pageRollTimer);
                this.destroyEvent();
                this.animation = true;

                // 滚动超过容器移动高度极限，后续动画将自动完成
                if (this.pageOffsetY > 0) {
                    // 上一页
                    this._pageNum--;
                    this.pageOffsetY = containerHeight;
                } else if (this.pageOffsetY < 0) {
                    // 下一页
                    this._pageNum++;
                    this.pageOffsetY = -containerHeight;
                }

                // 展示页码
                this.pageNumModalVisible = true;

                /*
                等待当前页移走动画展示完毕，然后关闭动画持续时间（动画将瞬间完成，利用这点将页面位置复原）
                */
                await delay(this.animationDuration * 1000);
                this.animation = false;
                if (this.togglePageType === "slide") {
                    this.pageOffsetY = -this.pageOffsetY;
                } else if (this.togglePageType === "instantly") {
                    this.pageOffsetY = 0;
                }

                // 触发页码改变事件
                this.$emit("pageChange", this._pageNum);

                /*
                这里需要等待一个动画持续时间，否则复原动画将不能瞬间完成
                */
                await delay(this.animationDuration * 1000);
                this.animation = true;
                if (this.togglePageType === "slide") {
                    this.pageOffsetY = 0;
                } else if (this.togglePageType === "instantly") {
                }

                /*
                等待上一页/下一页动画展示完毕，关闭页码遮罩，并且重新绑定事件
                */
                await delay(this.animationDuration * 1000);
                this.pageNumModalVisible = false;
                this.initEvent();
            } else {
                this.animation = true;
                if (this.pageRollTimer) clearTimeout(this.pageRollTimer);
                this.pageRollTimer = setTimeout(() => {
                    this.pageOffsetY = 0;
                    this.pageRollTimer = 0;
                }, this.pageRollInterval);
            }
        },
    },
};
</script>

<style scoped>
.web-page-swiper {
    overflow: hidden;
    position: relative;
}

.web-page-swiper.grab * {
    cursor: grab;
}

.web-page-swiper>.prev-page-loading,
.web-page-swiper>.next-page-loading,
.web-page-swiper>.current-page {
    position: absolute;
    left: 0%;
    width: 100%;
    height: 100%;
    transition: var(--page-transition) var(--animation-duration);
}

.web-page-swiper>.prev-page-loading.prev-page-loading,
.web-page-swiper>.next-page-loading.prev-page-loading,
.web-page-swiper>.current-page.prev-page-loading {
    top: calc((1 - 2) * 100% + var(--offset-y));
}

.web-page-swiper>.prev-page-loading.current-page,
.web-page-swiper>.next-page-loading.current-page,
.web-page-swiper>.current-page.current-page {
    top: calc((2 - 2) * 100% + var(--offset-y));
}

.web-page-swiper>.prev-page-loading.next-page-loading,
.web-page-swiper>.next-page-loading.next-page-loading,
.web-page-swiper>.current-page.next-page-loading {
    top: calc((3 - 2) * 100% + var(--offset-y));
}

.web-page-swiper>.prev-page-loading,
.web-page-swiper>.next-page-loading {
    display: flex;
    flex-direction: column;
    align-items: center;
    opacity: 0;
}

.web-page-swiper>.prev-page-loading>div,
.web-page-swiper>.next-page-loading>div {
    margin: 1rem 0;
}

.web-page-swiper>.prev-page-loading.show,
.web-page-swiper>.next-page-loading.show {
    opacity: 1;
}

.web-page-swiper>.prev-page-loading {
    justify-content: end;
}

.web-page-swiper>.next-page-loading {
    justify-content: start;
}

.web-page-swiper>.modal {
    display: flex;
    justify-content: center;
    align-items: center;
    position: absolute;
    left: 0%;
    top: 0%;
    width: 100%;
    height: 100%;
    font-size: 5rem;
    font-weight: 700;
    color: white;
    background-color: black;
    transition: opacity var(--animation-duration);
    opacity: 0;
    pointer-events: none;
}

.web-page-swiper>.modal.show {
    pointer-events: all;
    opacity: var(--page-modal-opacity);
}
</style>