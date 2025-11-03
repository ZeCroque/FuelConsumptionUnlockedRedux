#pragma once

#include <intrin.h>
#include <functional>
#include <memory>
#if _HAS_CXX20
#include <span>
#endif
#include <algorithm>

#define DEFINE_STATIC_HEAPCustom(staticAllocate, staticFree)                                                                                                                             \
    static void* operator new(std::size_t size)                                                                                                                                    \
    {                                                                                                                                                                              \
        return staticAllocate(size);                                                                                                                                               \
    }                                                                                                                                                                              \
    static void* operator new(std::size_t size, const std::nothrow_t&)                                                                                                             \
    {                                                                                                                                                                              \
        return staticAllocate(size);                                                                                                                                               \
    }                                                                                                                                                                              \
    static void* operator new(std::size_t size, void* ptr)                                                                                                                         \
    {                                                                                                                                                                              \
        return ptr;                                                                                                                                                                \
    }                                                                                                                                                                              \
    static void operator delete(void* ptr)                                                                                                                                         \
    {                                                                                                                                                                              \
        staticFree(ptr);                                                                                                                                                           \
    }                                                                                                                                                                              \
    static void operator delete(void* ptr, const std::nothrow_t&)                                                                                                                  \
    {                                                                                                                                                                              \
        staticFree(ptr);                                                                                                                                                           \
    }                                                                                                                                                                              \
    static void operator delete(void*, void*) {}



void* Heap_AllocateCustom(size_t size)
{
    return RE::MemoryManager::GetSingleton()->Allocate(size, 0, false);
}

void Heap_FreeCustom(void* ptr)
{
    RE::MemoryManager::GetSingleton()->Free(ptr, false);
}

//RE::MemoryManager* GetMemoryManager() {
//    return RE::MemoryManager::GetSingleton();
//}





class BSTArrayCustomBaseCustom
{
public:
    using size_type = uint32_t;

    BSTArrayCustomBaseCustom() : uiSize(0), uiAllocSize(0) {}

    struct IAllocatorFunctor
    {
        virtual bool Allocate(uint32_t auiMinNewSize, uint32_t auiElemSize)                                                                          = 0;
        virtual bool Reallocate(uint32_t auiMinNewSizeInItems, uint32_t auiFrontCopyCount, uint32_t auiShiftCount, uint32_t auiBackCopyCount, uint32_t auiElemSize) = 0;
        virtual void Deallocate()                                                                                                          = 0;
        virtual ~IAllocatorFunctor(){};
    };

    size_type uiSize;      // 00
    size_type uiAllocSize; // 04

    [[nodiscard]] size_type size() const noexcept { return uiSize; }

    [[nodiscard]] size_type capacity() const noexcept { return uiAllocSize; }

    void set_capacity(size_type a_capacity, size_type) noexcept { uiAllocSize = a_capacity; }
};

template <typename T>
class BSTArrayCustomAllocatorFunctorCustom : public BSTArrayCustomBaseCustom::IAllocatorFunctor
{
public:
    T* pAllocator; // 00
};

class BSTArrayCustomHeapAllocatorCustom
{
public:
    [[nodiscard]] void* allocate(uint32_t a_bytes) { return RE::MemoryManager::GetSingleton()->Allocate(a_bytes, 0, false); }

    void deallocate(void* a_ptr) { RE::MemoryManager::GetSingleton()->Free(a_ptr, false); }
};

class BSScrapArrayAllocatorCustom
{
public:
    void* pScrapHeap; // 00
};

template <typename T, class Allocator = BSTArrayCustomHeapAllocatorCustom>
class BSTArrayCustom : public BSTArrayCustomBaseCustom, public Allocator
{
public:
    using value_type             = T;
    using allocator_type         = Allocator;
    using size_type              = std::uint32_t;
    using difference_type        = std::ptrdiff_t;
    using reference              = value_type&;
    using const_reference        = const value_type&;
    using pointer                = value_type*;
    using const_pointer          = const value_type*;
    using iterator               = pointer;
    using const_iterator         = const_pointer;
    using reverse_iterator       = std::reverse_iterator<iterator>;
    using const_reverse_iterator = std::reverse_iterator<const_iterator>;

    BSTArrayCustom() : pData(nullptr) {}

    [[nodiscard]] iterator begin() noexcept { return pData; }

    [[nodiscard]] iterator end() noexcept { return begin() + uiSize; }

    [[nodiscard]] reference front() noexcept { return *begin(); }

    [[nodiscard]] reference back() noexcept { return *std::prev(end()); }

    [[nodiscard]] const_iterator cbegin() const noexcept { return pData; }

    [[nodiscard]] const_iterator cend() const noexcept { return cbegin() + uiSize; }

    [[nodiscard]] size_type max_size() const noexcept { return (std::numeric_limits<size_type>::max)(); }

    [[nodiscard]] size_type capacity() const noexcept { return uiAllocSize; }

    void clear() { erase(begin(), end()); }

    value_type& at(uint32_t i) const noexcept { return pData[i]; }

    void push_back(value_type&& x) { emplace_back(std::move(x)); }

    reference operator[](size_type n) { return pData[n]; }

    const_reference operator[](size_type n) const { return pData[n]; }

#if !_HAS_CXX20
    template <typename _Tp, typename... _Args>
    constexpr auto construct_at(_Tp* __location, _Args&&... __args) noexcept(noexcept(::new((void*)0) _Tp(std::declval<_Args>()...)))
        -> decltype(::new((void*)0) _Tp(std::declval<_Args>()...))
    {
        return ::new ((void*)__location) _Tp(std::forward<_Args>(__args)...);
    }
#endif

    bool empty() const { return size() == 0; }

    template <class ForwardIt>
    iterator insert(const_iterator a_pos, ForwardIt a_first, ForwardIt a_last) //
    {
        const auto distance = static_cast<size_type>(std::distance(a_first, a_last));
        if (distance == 0) {
            return decay_iterator(a_pos);
        }

        const auto pos = static_cast<size_type>(std::distance(cbegin(), a_pos));
        resize(size() + distance);
        const auto iter = begin() + pos;
        std::move_backward(iter, iter + distance, end());
        std::copy(a_first, a_last, iter);
        return iter;
    }

    template <class... Args>
    iterator emplace(const_iterator a_pos, Args&&... a_args)
    {
        const auto pos = static_cast<size_type>(std::distance(cbegin(), a_pos));
        if (pos < size()) {
            emplace_back(std::move(back()));
            std::move_backward(begin() + pos, end() - 2, end() - 1);
        }
        else {
            reserve_auto(size() + 1);
            uiSize += 1;
        }
#if _HAS_CXX20
        std::construct_at(data() + pos, std::forward<Args>(a_args)...);
#else
        construct_at(data() + pos, std::forward<Args>(a_args)...);
#endif
        return begin() + pos;
    }

    iterator erase(const_iterator a_first, const_iterator a_last)
    {
        const auto first    = decay_iterator(a_first);
        const auto last     = decay_iterator(a_last);
        const auto distance = static_cast<size_type>(std::distance(first, last));
        if (distance == 0) {
            return last;
        }

        std::move(last, end(), first);
        std::destroy(end() - distance, end());
        uiSize -= distance;
        return end();
    }

    iterator erase(const_iterator a_pos) { return erase(a_pos, std::next(a_pos)); }

    template <class... Args>
    reference emplace_back(Args&&... a_args)
    {
        return *emplace(end(), std::forward<Args>(a_args)...);
    }

    void pop_back() { erase(std::prev(end())); }

    void resize(size_type a_count) { resize_impl(a_count, nullptr); }

    void resize(size_type a_count, const value_type& a_value) { resize_impl(a_count, std::addressof(a_value)); }

    void swap(BSTArrayCustom& a_rhs)
    {
        auto tmp = std::move(*this);
        *this    = std::move(a_rhs);
        a_rhs    = std::move(tmp);
    }

    DEFINE_STATIC_HEAPCustom(Heap_AllocateCustom, Heap_FreeCustom)

private:
    [[nodiscard]] iterator decay_iterator(const_iterator a_iter) noexcept { return const_cast<pointer>(std::addressof(*a_iter)); }

    void reserve_auto(size_type a_capacity)
    {
        if (a_capacity > capacity()) {
            const auto grow = (std::max)(a_capacity, capacity() * 2);
            reserve_exact(grow);
        }
    }

    void reserve_exact(size_type a_capacity)
    {
        if (a_capacity == capacity()) {
            return;
        }

        const auto ndata = static_cast<pointer>(allocator_type().allocate(a_capacity * sizeof(value_type)));
        const auto odata = data();
        if (ndata != odata) {
            std::uninitialized_move_n(odata, size(), ndata);
            std::destroy_n(odata, size());
            allocator_type().deallocate(odata);
            set_data(ndata);
            set_capacity(a_capacity, a_capacity * sizeof(value_type));
        }
    }

    void resize_impl(size_type a_count, const value_type* a_value)
    {
        if (a_count < size()) {
            erase(begin() + a_count, end());
        }
        else if (a_count > size()) {
            reserve_auto(a_count);
#if _HAS_CXX20
            std::span<value_type> range{ data() + uiSize, a_count - uiSize };
            if (a_value) {
                std::for_each(range.begin(), range.end(), [=](auto& a_elem) { std::construct_at(std::addressof(a_elem), *a_value); });
            }
            else {
                std::uninitialized_default_construct(range.begin(), range.end());
            }
#else
            if (a_value) {
                for (size_type i = uiSize; i < a_count - uiSize; ++i) {
                    construct_at(std::addressof(data() + i), *a_value);
                }
            }
            else {
                std::uninitialized_default_construct_n(data() + uiSize, a_count - uiSize);
            }
#endif
            uiSize = a_count;
        }
    }

    [[nodiscard]] T* data() noexcept { return pData; }

    [[nodiscard]] const T* data() const noexcept { return pData; }

    void set_data(T* a_data) noexcept { pData = a_data; }

    T* pData; // 08 or 10
};

static_assert(sizeof(BSTArrayCustom<void*>) == 0x10);
