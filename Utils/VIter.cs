
namespace CC.Utils
{
    public struct VIter<T>
    {
        private readonly T[] _array;
        private int _index;

        public VIter( T[] array )
        {
            _array = array;
            _index = 0;
        }

        public T GetCurrent()
        {
            return _array[_index];
        }

        public bool End()
        {
            return _index >= _array.Length;
        }

        public void MoveNext()
        {
            _index++;
        }

        public int GetIndex()
        {
            return _index;
        }
    }
}
